class User < ActiveRecord::Base
  def self.current_user
    Thread.current[:current_user]
  end

  def self.current_user=(usr)
    Thread.current[:current_user] = usr
  end
  has_one :user_address
  has_many :bookrequests
  has_many :assignments, :dependent => :destroy
  has_many :roles, through: :assignments
  has_many :teacher_courses
  has_many :degree_course_assignments, through: :teacher_courses
  has_many :test
  has_many :user_test_histories
  has_many :question_histories
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, :omniauth_providers => [:facebook]

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :role, :name, :phone,
                  :role_id, :provider, :uid
  # attr_accessible :title, :body

  attr_accessible :avatar
  has_attached_file :avatar, :styles => { :medium => "300x300>", :thumb => "100x100>" },
                    :default_url => "/images/:style/missing.png",
                    :storage => :s3,
                    :url => 's3_domain_url',
                    :s3_host_alias => 'elslearning.s3-website-us-east-1.amazonaws.com',
                    :s3_credentials => File.join(Rails.root, 'config', 's3.yml'),
                    :path => "/files/:style/:id_:filename"

  validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/
  def is_admin?
    return true if(self.roles.first.name.eql?("Admin") unless self.roles.nil?)
  end

  def is_operator?
    return true if(self.roles.first.name.eql?("Operator") unless self.roles.nil?)
  end
  def is_teacher?
    return true if(self.roles.first.name.eql?("Teacher") unless self.roles.nil?)
  end
  def is_proofreader?
    return true if(self.roles.first.name.eql?("Proof Reader") unless self.roles.nil?)
  end
  def is_student?
    return true if(self.roles.first.name.eql?("Student") unless self.roles.nil?)
  end

  def is_not_student?
    return true if(self.roles.first.name.eql?("Admin") ||
                   self.roles.first.name.eql?("Operator") ||
                   self.roles.first.name.eql?("Teacher") ) ||
                   self.roles.first.name.eql?("Proof Reader")
  end
  def self.from_omniauth(auth)
    user = User.where(:provider => auth.provider, :uid => auth.uid).first
    if user
      return user
    else
      registered_user = User.where(:email => auth.info.email).first
      if registered_user
        return registered_user
      else
        user = User.create(:name=> auth.extra.raw_info.name,
                               :provider => auth.provider,
                               :uid => auth.uid,
                               :email => auth.info.email,
                               :password => Devise.friendly_token[0,20],
                               :avatar => auth.info.image.split("=")[0].gsub('http://','https://')+"?type=large"
        )
        assignment = {'user_id'=>user.id,'role_id'=>4}
        @assignment = Assignment.new(assignment)
        @assignment.save
        return user
      end
    end
  end
end
