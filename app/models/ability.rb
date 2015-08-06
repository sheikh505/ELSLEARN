class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:
    #
       user ||= User.new # guest user (not logged in)

       unless user.id.nil?
         if user.is_admin?
           can :manage, :all

         elsif user.is_teacher? || user.is_hod?
           can :read, Board
           can :read, Degree
           can :read, Course
           can :manage, Topic
           can :manage, Quiz do |quiz|
             quiz.user.email == user.email
           end
           can :manage, Question do |question|
             question.author == user.email
           end
         elsif user.is_operator?
           can :read, Board
           can :read, Degree
           can :read, Course
           can :read, Topic
           can :manage, Question do |question|
             question.author == user.email
           end
         elsif user.is_proofreader?
           can :read, Board
           can :read, Degree
           can :read, Course
           can :read, Quiz
           can :read, Topic
           can :manage, Question
         #   do |question|
         #       User.find_by_email(question.author.to_s).id == user.role
         # end
         else
           #can :manage, :all
         end
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
