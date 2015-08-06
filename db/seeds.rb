# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
def create_admin
user=User.new
user.email = 'admin@els.com'
user.password = 'Pakistan123'
  user.role = 'admin'
user.name = 'Admin'
  user.save
  #user.roles.build(description: 'admin')
end

def create_roles
  newrole = {"name"=>"Admin"}
  role = Role.new(newrole)
  role.save
  users = User.all
  users.each do |user|
    newassignment = {"user_id"=>user.id, "role_id"=>role.id}
    assignment = Assignment.new(newassignment)
    assignment.save
  end
end
#userTemp = User.find_by_name('Admin')
#userTemp.destroy if userTemp.is_admin?
create_admin
create_roles