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
  #Associate lessons with readings (both directions).
  def test_lessons_associated_with_readings
    l = Lesson.create(name: "First Lesson")
    r = Reading.create(caption: "First Reading")
    l.readings << r

    assert_equal [r], Lesson.find(l.id).readings
  end

  #When a lesson is destroyed, its readings should be automatically destroyed.
  def test_reading_destroyed_when_lesson_destroyed
    l = Lesson.create(name: "First Lesson")
    r = Reading.create(caption: "First Reading")
    l.readings << r
    assert_equal 1, l.readings.count
    Lesson.destroy_all
    assert_equal 0, l.readings.count
  end

  #Associate courses with lessons (both directions).
  def test_courses_associated_with_lessons
    l = Lesson.create(name: "First Lesson")
    c = Course.create(name: "Computer Science")
    c.lessons << l
    assert_equal [l], Course.find(c.id).lessons
  end

  #When a course is destroyed, its lessons should be automatically destroyed.
  def test_lessons_destroyed_when_course_destroyed
    l = Lesson.create(name: "First Lesson")
    c = Course.create(name: "Computer Science")
    c.lessons << l
    assert_equal 1, c.lessons.count
    Course.destroy_all
    assert_equal 0, c.lessons.count
  end

  #Associate courses with course_instructors (both directions).
  def test_course_instructors_associated_with_courses
    c = Course.create(name: "Computer Science")
    i = CourseInstructor.create()
    c.course_instructors << i
    assert_equal [i], Course.find(c.id).course_instructors
  end

  #If the course has any students associated with it, the course should not be deletable.
  def test_if_course_has_students_course_cannot_be_deleted
    Course.destroy_all
    c = Course.create(name: "Computer Science")
    assert_equal 1, Course.count
    Course.destroy_all
    assert_equal 0, Course.count

    c2 = Course.create(name: "Ruby on Rails")
    s = CourseStudent.create()
    c2.course_students << s
    assert_equal 1, Course.count
    Course.destroy_all
    assert_equal 1, Course.count
  end

  #Associate lessons with their in_class_assignments (both directions).
  def test_lessons_associated_with_in_class_assignments
    l = Lesson.create(name: "First Lesson")
    a = Assignment.create(course_id: 3, name: "Unique Assignment", percent_of_grade: 20.00)
    a.lessons << l

    assert_equal [l], Assignment.find(a.id).lessons
  end

  # Set up a Course to have many readings through the Course's lessons.
  def test_course_associated_with_readings_through_lessons
    c = Course.create(name: "Computer Science")
    l = Lesson.create(name: "First Lesson")
    r = Reading.create(caption: "First Reading")
    l.readings << r
    c.lessons << l
    assert_equal [r], Course.find(c.id).readings
  end

  #Validate that Schools must have name.
  def test_schools_must_have_names
    s = School.new()
    refute s.save
  end

  #Validate that Terms must have name, starts_on, ends_on.
  def test_terms_must_have_qualities
    t = Term.new()
    refute t.save
    t1 = Term.new(name: "Summer", starts_on: 2015-01-04)
    refute t1.save
  end

  # Terms must have a school_id.
  def test_terms_associated_with_schools
    t = Term.create(name: "Summer", starts_on: 2015-01-04, ends_on: 2015-06-02)
    s = School.create(name: "Iron Yard")
    s.add_term(t)
    assert_equal [t], School.find(s.id).terms
  end

  #Validate that the User has a first_name, a last_name, and an email.
  def test_users_must_have_qualities
    u = User.new()
    refute u.save
    u2 = User.new(first_name: "Ilan", last_name: "Man")
    refute u2.save
  end

  #Validate that the User's email is unique.
  def test_unique_user_email
    assert User.create(first_name: "Ilan", last_name: "Man", email: "ilan@gmail.com")
    u = User.new(first_name: "Aliza", last_name: "Barkel", email: "ilan@gmail.com")
    refute u.save
  end

  # Validate that the User's email has the appropriate form for an e-mail address. Use a regular expression.
  def test_user_email_has_email_format
    assert User.create(first_name: "Ilan", last_name: "Man", email: "ilan@gmail.com")
    u = User.new(first_name: "Aliza", last_name: "Barkel", email: "ilan")
    refute u.save
    u2 = User.new(first_name: "Aliza", last_name: "Barkel", email: "@hi.com")
    refute u2.save
  end

  # Validate that the User's photo_url must start with http:// or https://. Use a regular expression.
  def test_user_email_has_photo_url_format
    assert User.create(first_name: "Ilan", last_name: "Man", email: "ilan@gmail.com", photo_url: "http://www.photourl.com")
    assert User.create(first_name: "Ruti", last_name: "Wajnberg", email: "ruti@gmail.com", photo_url: "https://www.photourl.com")
    u = User.new(first_name: "Aliza", last_name: "Barkel", email: "aliza@gmail.com", photo_url: "www.photourl.com")
    refute u.save
    u2 = User.new(first_name: "Steven", last_name: "Barkel", email: "steven@gmail.com", photo_url: "photourl.com")
    refute u2.save
  end

  # Validate that Assignments have a course_id, name, and percent_of_grade.
  def test_assignments_must_have_qualities
    a = Assignment.create(course_id: 3, name: "Assignment 3", percent_of_grade: 20.00)
    a1 = Assignment.new(course_id: 3, name: "Assignment 3")
    refute a1.save
    a2 = Assignment.new(course_id: 4)
    refute a2.save
  end

  # Validate that the Assignment name is unique within a given course_id.
  def test_unique_assignment_name_within_course_id
    a = Assignment.create(course_id: 1, name: "Assignment 1", percent_of_grade: 20.00)
    a1 = Assignment.new(course_id: 2, name: "Assignment 1", percent_of_grade: 20.00)
    assert a1.save
    a2 = Assignment.create(course_id: 3, name: "Assignment 3", percent_of_grade: 20.00)
    a3 = Assignment.new(course_id: 3, name: "Assignment 3", percent_of_grade: 20.00)
    refute a3.save
  end

<<<<<<< HEAD
  def test_course_students_associated_with_students
    cs = CourseStudent.create()
    i = CourseInstructor.create()
    c.course_instructors << i
    assert_equal [i], Course.find(c.id).course_instructors
  end

=======
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
    Course.create(course_code: "ABC 123", term_id: 1, name: "Poops")
    c = Course.new(course_code: "ABC 123", term_id: 2, name: "Don't poops")
    assert c.save
    Course.create(course_code: "DEF 780", term_id: 3, name: "Everybody poops")
    d = Course.new(course_code: "DEF 780", term_id: 3, name: "Speak for yourself, buddy")
    refute d.save
  end

  # Validate that the course_code starts with three letters and ends with three numbers. Use a regular expression.
  def test_course_code_start_letter_end_number_12
    Course.create(course_code: "ABC123", name: "Crashing Cars 101", term_id: 1)
    d = Course.new(course_code: "ABC123", name: "Crashing Cars 101", term_id: 2)
    assert d.save
    Course.create(course_code: "DEF 234", name: "Crashing Cars 101", term_id: 3)
    e = Course.new(course_code: "DEF 234", name: "Crashing Cars 101", term_id: 4)
    assert e.save
  end
>>>>>>> 75b23dc5fb367ad3609bf829e6c3abf54915926e
end
