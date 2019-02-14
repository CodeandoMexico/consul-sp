class Users::SessionsController < Devise::SessionsController

  private

    def after_sign_in_path_for(resource)
      if !verifying_via_email? && resource.show_welcome_screen?
        welcome_path
      else
        super
      end
    end

    def after_sign_out_path_for(resource)
      request.referer.present? && !request.referer.match("management") ? request.referer : super
    end

    def verifying_via_email?
      return false if resource.blank?
      stored_path = session[stored_location_key_for(resource)] || ""
      stored_path[0..5] == "/email"
    end

end


# header {
#     background: #EEE7E0;
#     border-bottom: 1px solid #dee0e3;
#     margin-bottom: 1.45rem;
# }
#
# .top-bar {
#     background: #EEE7E0 !important;
#     color: #fff;
#     padding-bottom: 0;
#     padding-top: 0;}
#
#     .subnavigation {
#         background: #6C6E72;
#         padding-bottom: 0;
#     }
#
#     a.is-active {
#     border-bottom: 2px solid #e8edf0;
#     color: #eaf0f5;
# }
#
# .subnavigation a {
#     color: #edf2f6;
#     display: block;
#     font-weight: bold;
#     width: auto;
# }
