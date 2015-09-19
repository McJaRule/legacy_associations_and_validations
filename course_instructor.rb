class CourseInstructor < ActiveRecord::Base
  belongs_to :instructor, class_name: "CourseInstructor"
  belongs_to :course

  # def add_course(course)
  #   courses << course
  # end

end
