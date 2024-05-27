# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  before_action :ensure_normal_user, only: %i[update destroy]

  def ensure_normal_user
    if resource.email == 'guest@example.com'
      redirect_to root_path, alert: 'ゲストユーザーは変更・削除できません。'
    end
  end
  
  protected

  #ユーザー情報を変更する際に、パスワードの入力を無しにする設定
  def update_resource(resource, params)
    resource.update_without_password(params)
  end

  def after_update_path_for(resource)
    profile_users_path
  end
end
