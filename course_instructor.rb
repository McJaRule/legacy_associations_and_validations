class CourseInstructor < ActiveRecord::Base
  belongs_to :instructor, class_name: "CourseInstructor"
  belongs_to :course


end
