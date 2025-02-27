# https://stackoverflow.com/questions/79142158/rails-8-authenticated-routes-for-rails-g-autentication

class UnauthorizedError < StandardError
end

class AuthMiddleware
  def initialize app
    @app = app
  end

  def call env
    request = ActionDispatch::Request.new(env)
    Current.session = Session.find_by(id: request.cookie_jar.signed[:session_id])

    @app.call(env)
  rescue UnauthorizedError
    [302, {Location: "/session/new"}, []]
  end
end

Rails.application.config.middleware.use AuthMiddleware