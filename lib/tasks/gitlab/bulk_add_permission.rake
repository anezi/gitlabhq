namespace :gitlab do
  namespace :import do
    desc "GITLAB | Add all users to all projects (admin users are added as masters)"
    task all_users_to_all_projects: :environment  do |t, args|
      user_ids = User.where(admin: false).pluck(:id)
      admin_ids = User.where(admin: true).pluck(:id)
      projects_ids = Project.pluck(:id)

      puts "Importing #{user_ids.size} users into #{projects_ids.size} projects"
      UsersProject.add_users_into_projects(projects_ids, user_ids, UsersProject::DEVELOPER)

      puts "Importing #{admin_ids.size} admins into #{projects_ids.size} projects"
      UsersProject.add_users_into_projects(projects_ids, admin_ids, UsersProject::MASTER)
    end

    desc "GITLAB | Add a specific user to all projects (as a developer)"
    task :user_to_projects, [:email] => :environment  do |t, args|
      user = User.find_by(email: args.email)
      project_ids = Project.pluck(:id)
      puts "Importing #{user.email} users into #{project_ids.size} projects"
      UsersProject.add_users_into_projects(project_ids, Array.wrap(user.id), UsersProject::DEVELOPER)
    end

    desc "GITLAB | Add all users to all groups (admin users are added as owners)"
    task all_users_to_all_groups: :environment  do |t, args|
      user_ids = User.where(admin: false).pluck(:id)
      admin_ids = User.where(admin: true).pluck(:id)
      groups = Group.all

      puts "Importing #{user_ids.size} users into #{groups.size} groups"
      puts "Importing #{admin_ids.size} admins into #{groups.size} groups"
      groups.each do |group|
        group.add_users(user_ids, UsersGroup::DEVELOPER)
        group.add_users(admin_ids, UsersGroup::OWNER)
      end
    end

    desc "GITLAB | Add a specific user to all groups (as a developer)"
    task :user_to_groups, [:email] => :environment  do |t, args|
      user = User.find_by_email args.email
      groups = Group.all
      puts "Importing #{user.email} users into #{groups.size} groups"
      groups.each do |group|
        group.add_users(Array.wrap(user.id), UsersGroup::DEVELOPER)
      end
    end
  end
end
