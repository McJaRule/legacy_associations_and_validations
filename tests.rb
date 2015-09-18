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

#Associate lessons with readings (both directions).
  def test_lessons_associated_with_readings
    l = Lesson.create(name: "First Lesson")
    r = Reading.create(caption: "First Reading")
    l.add_reading(r)
    assert_equal [r], Lesson.find(l.id).readings
  end

#When a lesson is destroyed, its readings should be automatically destroyed.
  def test_reading_destroyed_when_lesson_destroyed
    l = Lesson.create(name: "First Lesson")
    r = Reading.create(caption: "First Reading")
    l.add_reading(r)
    assert_equal 1, l.readings.count
    Lesson.destroy_all
    assert_equal 0, l.readings.count
  end

  #Associate courses with lessons (both directions).
  def test_courses_associated_with_lessons
    l = Lesson.create(name: "First Lesson")
    c = Course.create(name: "Computer Science")
    c.add_lesson(l)
    assert_equal [l], Course.find(c.id).lessons
  end

#When a course is destroyed, its lessons should be automatically destroyed.
  def test_lessons_destroyed_when_course_destroyed
    l = Lesson.create(name: "First Lesson")
    c = Course.create(name: "Computer Science")
    c.add_lesson(l)
    assert_equal 1, c.lessons.count
    Course.destroy_all
    assert_equal 0, c.lessons.count
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


#Associate courses with course_instructors (both directions).
  # def test_course_instructors_associated_with_courses
  #   c = Course.create(name: "Computer Science")
  #   i = CourseInstructor.create(instructor_id: 1)
  #   i.add_course(c)
  #   assert_equal [c], CourseInstructor.find(i.id).courses
  # end

#If the course has any students associated with it, the course should not be deletable.


end
