module ActivateApp
  class App < Padrino::Application
    register Padrino::Rendering
    register Padrino::Helpers
    register WillPaginate::Sinatra
    helpers Activate::DatetimeHelpers
    helpers Activate::ParamHelpers
    helpers Activate::NavigationHelpers
    
    if Padrino.env == :production
      register Padrino::Cache
      enable :caching 
    end
      
    require 'sass/plugin/rack'
    Sass::Plugin.options[:template_location] = Padrino.root('app', 'assets', 'stylesheets')
    Sass::Plugin.options[:css_location] = Padrino.root('app', 'assets', 'stylesheets')
    use Sass::Plugin::Rack

    set :sessions, :expire_after => 1.year
    set :public_folder, Padrino.root('app', 'assets')
    set :default_builder, 'ActivateFormBuilder'

    Mail.defaults do
      delivery_method :smtp, {
        :user_name => ENV['SMTP_USERNAME'],
        :password => ENV['SMTP_PASSWORD'],
        :address => ENV['SMTP_ADDRESS'],
        :port => 587
      }
    end

    before do
      @cachebuster = (Padrino.env == :development) ? SecureRandom.uuid : ENV['HEROKU_SLUG_COMMIT']
      redirect "#{ENV['BASE_URI']}#{request.path}" if ENV['BASE_URI'] && (ENV['BASE_URI'] != "#{request.scheme}://#{request.env['HTTP_HOST']}")
      if Padrino.env == :production && params[:r]
        ActivateApp::App.cache.clear
        redirect request.path
      end      
      fix_params!
      Time.zone = 'London'
      @og_desc = ''
      @og_image = "#{ENV['BASE_URI']}/images/link.png"
      @categories = Category.all(sort: { 'Order' => 'asc' })
      @category_names = @categories.map { |category| category['Name'] }      
      @base_color = '#EFD875'
      @n = @category_names.count
      @spin = 360/@n
      @colors = 0.upto(@n-1).map { |i| @base_color.paint.spin(i*@spin) }
      @base_bg_color = @base_color.paint.lighten(17)
      @bg_colors = 0.upto(@n-1).map { |i| @base_bg_color.paint.spin(i*@spin) }            
    end

    error do
      Airbrake.notify(env['sinatra.error'],
        url: "#{ENV['BASE_URI']}#{request.path}",
        params: params,        
        request: request.env.select { |k,v| v.is_a?(String) },
        session: session
      )
      erb :error, :layout => :application
    end

    not_found do
      erb :not_found, :layout => :application
    end

    get '/', :cache => true do
      erb :home
    end
    
    get '/:slug', :cache => true do
      @alternative = Alternative.all(filter: "{Slug} = '#{params[:slug]}'").first || not_found
      @title = @alternative['Name']
      @og_desc = @alternative['Description']
      @og_image = @alternative['Images'].first['URL']
      erb :alternative
    end
    
  end
end

