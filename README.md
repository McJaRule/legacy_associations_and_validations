# Legacy Associations and Validations

## Description

This program creates relationships and requirements on schools.

## Details

* Schools have many terms, and terms have many courses. It a term has courses, it cannot be deleted.
* Schools also have many courses (through terms) and readings (through lessons).
* Courses have students, and cannot be deleted if they contain any students.
* Courses also have assignments, and cannot be deleted if they contain any assignments.
* Courses also have lessons, and when a course is removed from the database, its lessons are as well.
* Course instructors have courses.
* Lessons have pre-class and in-class assignments. Be able to branch your code
* Lessons have many readings, and if a lessons is removed from the database, its readings are as well.
* Schools must have a name.
* Lessons must have names.
* Readings must have an order_number, a lesson_id, and a url.
* Courses must have a course_code and name. Course code must be unique within a given term_id. Course code must start with three letters and ends with three numbers.
* Terms must have name, starts_on, ends_on, and school_id.
* User must have a first_name, a last_name, and an email. User's email must be unique and have the appropriate form for an e-mail address. User's photo_url must start with http:// or https://.
* Assignments must have a course_id, name, and percent_of_grade, and Assignment name must be unique within a given course_id.

## ERD

![alt tag](https://github.com/McJaRule/legacy_associations_validations/blob/master/Legacy%20Associations%20and%20Validations.png)
