module Travis::API::V3
  class Models::User < Model
    has_many :memberships,   dependent: :destroy
    has_many :permissions,   dependent: :destroy
    has_many :emails,        dependent: :destroy
    has_many :tokens,        dependent: :destroy
    has_many :organizations, through:   :memberships
    has_many :stars
    has_many :user_beta_features
    has_many :beta_features, through: :user_beta_features

    serialize :github_oauth_token, Travis::Settings::EncryptedColumn.new(disable: true)

    def repository_ids
      repositories.pluck(:id)
    end

    def repositories
      Models::Repository.where(owner_type: 'User', owner_id: id)
    end

    def token
      tokens.first_or_create.token
    end

    def starred_repository_ids
      @starred_repository_ids ||= stars.map(&:repository_id)
    end

    def permission?(roles, options = {})
      roles, options = nil, roles if roles.is_a?(Hash)
      scope = permissions.where(options)
      scope = scope.by_roles(roles) if roles
      scope.any?
    end

    def installation
      return @installation if defined? @installation
      @installation = Models::Installation.find_by(owner_type: 'User', owner_id: id)
    end
  end
end
