require 'active_record'

ActiveRecord::Base.establish_connection(
  adapter:  'sqlite3',
  database: 'development.sqlite3'
)

require './assignment_grade.rb'
require './assignment.rb'
require './course_instructor.rb'
require './course_student.rb'
require './course.rb'
require './lesson.rb'
require './reading.rb'
require './school.rb'
require './term.rb'
require './user.rb'


# DONE: Associate lessons with readings (both directions). When a lesson is destroyed, its readings should be automatically destroyed.
# DONE: Associate lessons with courses (both directions). When a course is destroyed, its lessons should be automatically destroyed.
# DONE: Set up a Course to have many readings through the Course's lessons.
# DONE: Validate that Schools must have name.
# DONE: Validate that Terms must have name, starts_on, ends_on, and school_id.
# DONE: Validate that the User has a first_name, a last_name, and an email.
# DONE: Validate that the User's email is unique.
# DONE: Validate that the User's email has the appropriate form for an e-mail address. Use a regular expression.
# DONE: Validate that the User's photo_url must start with http:// or https://. Use a regular expression.
# DONE: Validate that Assignments have a course_id, name, and percent_of_grade.

# 1. Associate courses with course_instructors (both directions).
# - course instructors belong to instructors, but thats really a user. So when establish the belongs to, add a stipulation that that's really user.
# 2. If the course has any students associated with it, the course should not be deletable.
# 3. Associate lessons with their in_class_assignments (both directions).
# - figure out how to associate with through when non-linear
# 4. Validate that the Assignment name is unique within a given course_id.
