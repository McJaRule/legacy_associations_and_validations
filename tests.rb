# Basic test requires
require 'minitest/autorun'
require 'minitest/pride'

# Include both the migration and the app itself
require './migration'
require './application'

# Overwrite the development database connection with a test connection.
ActiveRecord::Base.establish_connection(
  adapter:  'sqlite3',
  database: 'test.sqlite3'
)

ActiveRecord::Migration.verbose = false

# Gotta run migrations before we can run tests.  Down will fail the first time,
# so we wrap it in a begin/rescue.



# Finally!  Let's test the thing.
class ApplicationTest < Minitest::Test

  def setup
    begin ApplicationMigration.migrate(:down); rescue; end
    ApplicationMigration.migrate(:up)
  end

  def test_truth
    assert true
  end

  # Associate schools with terms (both directions).
  def test_associate_schools_terms_01
    s = School.create(name: "The Iron Yard")
    t = Term.create(name: "Fall 2015")
    t.school_id = s.id
    assert_equal t.school_name, "The Iron Yard"
    assert_equal s.name, "The Iron Yard"
  end

  # Associate terms with courses (both directions). If a term has any courses associated with it, the term should not be deletable.
  def test_associate_terms_courses_02
    t = Term.create(name: "Fall 2015")
    c = Course.create(name: "Ruby on Rails")
    t.courses << c
    assert_equal 1, Term.count
    t.destroy
    assert_equal 1, Term.count
  end

  # Associate courses with course_students (both directions). If the course has any students associated with it, the course should not be deletable.
  def test_associate_courses_students_03
    timmy = CourseStudent.create(id: 1)
    horsies = Course.create(name: "Are horsies pretty?", course_code: "ABC 123")
    horsies.course_students << timmy
    assert_equal 1, Course.count
    horsies.destroy
    assert_equal 1, Course.count
  end

  # Associate assignments with courses (both directions). When a course is destroyed, its assignments should be automatically destroyed.
  # A course has many assignments
  def test_associate_assignments_courses_autoboom_assignments_04
    that_thing = Course.create(name: "Things 101", course_code: "ABC 123")
    did_you_get = Assignment.create(name: "Did you get that thing I sent ya?")
    that_thing.assignments << did_you_get
    assert_equal 1, Course.count
    that_thing.destroy
    assert_equal 0, Assignment.count
  end

  # Associate lessons with their pre_class_assignments (both directions).
  def test_associate_lessons_preassignments_05
    l = Lesson.create(name: "Get schooled")
    a = Assignment.create(name: "Learn something")
    a.lessons << l
    assert_equal 1, Assignment.count
  end

  # Set up a School to have many courses through the school's terms.
  def test_school_courses_thru_terms_06
    s = School.create(name: "The Iron Yard")
    c = Course.create(name: "Things 101")
    t = Term.create(name: "Fall 2015")
    t.courses << c
    s.terms << t
    assert s.courses.include?(c)
  end

  # Validate that Lessons have names.
  def test_lessons_can_haz_names_07
    Lesson.create(name: "Life Lesson")
    l = Lesson.new()
    refute l.save
  end

  # Validate that Readings must have an order_number, a lesson_id, and a url.
  def test_readings_must_order_number_lesson_id_and_url_08
    Reading.create(order_number: 1, lesson_id: 1, url: "http://lolcrazypants.com")
    r = Reading.new()
    refute r.save
  end

  # Validate that the Readings url must start with http:// or https://. Use a regular expression.
  def test_readings_url_must_start_with_http_09
    r = Reading.create(url: "http://www.boomboomroom.com")
    assert r.url.include?("http")
    s = Reading.new(url: "zombo.com")
    refute s.save
  end

  # Validate that Courses have a course_code and a name.
  def test_courses_haz_course_code_and_name_10
    b = Course.new()
    a = Course.create(course_code: "ABC 123", name: "Michael Jackson")
    assert a.name && a.course_code
    refute b.save
  end

  # Validate that the course_code is unique within a given term_id.
  def test_course_code_unique_within_term_11
  
  end
  #
  # # Validate that the course_code starts with three letters and ends with three numbers. Use a regular expression.
  # def test_course_code_start_letter_end_number_12
  #
  # end
end
