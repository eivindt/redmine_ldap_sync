Redmine::Plugin.register :redmine_ldap_sync do
  name 'Redmine LDAP Sync'
  author 'Ricardo Santos'
  author_url 'https://github.com/thorin'
  description 'Syncs users and groups with ldap'
  url 'https://github.com/thorin/redmine_ldap_sync'
  version '3.0.0'
  requires_redmine :version_or_higher => '7.0.0'

  settings :default => HashWithIndifferentAccess.new()
  menu :admin_menu, :ldap_sync, { :controller => 'ldap_settings', :action => 'index' }, :caption => :label_ldap_synchronization,
                    :icon => 'server-authentication',
                    :html => {:class => 'icon icon-ldap-sync'}
end

# Core extensions
require 'net/ldap'
Net::LDAP::Entry.include(Enumerable) unless Net::LDAP::Entry.include?(Enumerable)
unless ActiveSupport::Cache::FileStore.include?(LdapSync::CoreExt::FileStore)
  ActiveSupport::Cache::FileStore.include(LdapSync::CoreExt::FileStore)
end

# init.rb is re-run inside to_prepare on every code reload, and the
# plugin's lib/ directory is on the autoload path, so the patches can be
# applied directly here
User.include(LdapSync::Infectors::User) unless User.include?(LdapSync::Infectors::User)
Group.include(LdapSync::Infectors::Group) unless Group.include?(LdapSync::Infectors::Group)
unless AuthSourceLdap.include?(LdapSync::Infectors::AuthSourceLdap)
  AuthSourceLdap.include(LdapSync::Infectors::AuthSourceLdap)
end

# Referencing the hook listener forces the autoloader to load it so the
# view hooks are registered also in development mode
LdapSync::Hooks
