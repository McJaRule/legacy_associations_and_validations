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

# Gotta run migrations before we can run tests.  Down will fail the first time,
# so we wrap it in a begin/rescue.
begin ApplicationMigration.migrate(:down); rescue; end
ApplicationMigration.migrate(:up)


# Finally!  Let's test the thing.
class ApplicationTest < Minitest::Test

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
    assert t.reload.courses.include?(c)
    refute t.destroy
  end

  def test_term_undeletable_if_courses
    Term.destroy_all
    t = Term.create(name: "Fall 2015")
    assert_equal 1, Term.count
    t.destroy
    assert_equal 0, Term.count

    t = Term.create(name: "Fall 2015")
    c = Course.create(name: "Ruby on Rails")
    t.courses << c
    assert_equal 1, Term.count
    t.destroy
    assert_equal 1, Term.count
  end

  # # Associate courses with course_students (both directions). If the course has any students associated with it, the course should not be deletable.
  # def test_associate_courses_students_03
  #
  # end
  #
  # # Associate assignments with courses (both directions). When a course is destroyed, its assignments should be automatically destroyed.
  # def test_associate_assignments_courses_autoboom_assignments_04
  #
  # end
  #
  # # Associate lessons with their pre_class_assignments (both directions).
  # def test_associate_lessons_preassignments_05
  #
  # end
  #
  # # Set up a School to have many courses through the school's terms.
  # def test_school_courses_thru_terms_06
  #
  # end
  #
  # # Validate that Lessons have names.
  # def test_lessons_can_haz_names_07
  #
  # end
  #
  # # Validate that Readings must have an order_number, a lesson_id, and a url.
  # def test_readings_must_order_number_lesson_id_and_url_08
  #
  # end
  #
  # # Validate that the Readings url must start with http:// or https://. Use a regular expression.
  # def test_readings_url_must_start_with_http_09
  #
  # end
  #
  # # Validate that Courses have a course_code and a name.
  # def test_lessons_haz_course_code_and_name_10
  #
  # end
  #
  # # Validate that the course_code is unique within a given term_id.
  # def test_course_code_unique_within_term_11
  #
  # end
  #
  # # Validate that the course_code starts with three letters and ends with three numbers. Use a regular expression.
  # def test_course_code_start_letter_end_number_12
  #
  # end
end
