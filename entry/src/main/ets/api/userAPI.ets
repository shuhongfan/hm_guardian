import { LoginInfoResponse } from '../common/constants'
import { axiosInstance, AxiosResponseData } from '../common/utils/http'

interface postUserRegisterData {
  passwd: string
  phone: string
  smsCode: string
}

/* 注册用户 */
export function postUserRegisterAPI(data: postUserRegisterData) {
  return axiosInstance.post
  <null, AxiosResponseData<LoginInfoResponse>, postUserRegisterData>
  ('/user/register', data)
}

/** 账号密码登录 */
export interface postUserLoginPasswdData {
  /** 用户密码 */
  passwd: string;

  /** 用户手机号 */
  phone: string;
}


/* 密码登录 */
export function postUserLoginPasswdAPI(data: postUserLoginPasswdData) {
  return axiosInstance.post
  <null, AxiosResponseData<LoginInfoResponse>, postUserLoginPasswdData>
  ('/user/login/passwd', data)
}

/** 账号密码登录 */
export interface postUserLoginVerifyCodeData {
  /** 用户手机号 */
  phone: string;

  /** 用户密码 */
  verifyCode: string;
}

/* 通过验证码登录 */
export function postUserLoginVerifyCodeAPI(data: postUserLoginVerifyCodeData) {
  return axiosInstance.post
  <null, AxiosResponseData<LoginInfoResponse>, postUserLoginVerifyCodeData>
  ('/user/login/verifyCode', data)
}

export interface postUserSetPasswdData {
  /** 密码 */
  passwd: string;

  /** 手机号 */
  phone: string;

  /** 短信验证码 */
  smsCode: string;
}

/* 通过验证码登录 */
export function postUserSetPasswdAPI(data: postUserSetPasswdData) {
  return axiosInstance.post
  <null, AxiosResponseData<LoginInfoResponse>, postUserSetPasswdData>
  ('/user/setPasswd', data)
}

/** 获取用户信息 */
export interface UserInfoResponse {
  /** 头像 */
  avatar: string;

  /** 用户昵称 */
  nickname: string;
}

/* 获取我的用户信息 */
export function getUserInfoAPI() {
  return axiosInstance.get
  <null, AxiosResponseData<UserInfoResponse>, null>
  ('/user/me')
}

/* 用户信息保存 */
export function putUserInfoAPI(data: UserInfoResponse) {
  return axiosInstance.put
  <null, AxiosResponseData<null>, UserInfoResponse>
  ('/user/me', data)
}

/** token续期-请求参数 */
export interface postUserRenewalData {
  /** 续期token */
  renewalToken: string;
}

/* token续期 */
export function postUserRenewalAPI(data: postUserRenewalData) {
  return axiosInstance.post
  <null, AxiosResponseData<UserInfoResponse>, postUserRenewalData>
  ('/user/renewal', data)
}
