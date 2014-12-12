class User < ActiveRecord::Base
  has_one :user_address
  has_many :bookrequests
  has_many :assignments, :dependent => :destroy
  has_many :roles, through: :assignments
  has_many :teacher_courses
  has_many :degree_course_assignments, through: :teacher_courses
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :role, :name, :phone
  # attr_accessible :title, :body

  def is_admin?
    return true if(self.role.eql?("admin"))
  end

  def is_teacher?
    return true if(self.role.eql?("teacher"))
  end
  def is_student?
    return true if self.role == "user"
  end

  def is_not_student?
    return true if(self.role.eql?("admin") || self.role.eql?("teacher"))
  end
end
