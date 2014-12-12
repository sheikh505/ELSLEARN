# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
def create_admin
user=User.new
user.email = 'admin@umair.com'
user.password = 'umair123'
  user.role = 'admin'
user.name = 'Umair'
  user.save!
  #user.roles.build(description: 'admin')
end
create_admin