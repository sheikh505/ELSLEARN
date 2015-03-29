class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:
    #
       user ||= User.new # guest user (not logged in)
       if user.is_admin?
         can :manage, :all

       elsif user.is_operator?
         can :manage, Board
         can :manage, Degree
         can :manage, Course
         can :read, Question
         can :manage, Question do |item|
           item.author == user.email
         end
         can :manage, Option
       elsif user.is_teacher?

        can :manage, :all
        cannot :destroy,[Book,Course,Degree,Test,User]


       elsif user.is_student?
         can :read, Test
         can :read, Book
         can :manage, UserAddress
         can :manage, Bookrequest
       else
          cannot :manage,Teacher
       end
    #
    # The first argument to `can` is the action you are giving the user 
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. 
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/ryanb/cancan/wiki/Defining-Abilities







  end
end
