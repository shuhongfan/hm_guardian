import { axiosInstance, AxiosResponseData } from '../common/utils/http'

interface postCodeSmsSendData {
  bizType?: BizType
  phone: string
}

interface postCodeSmsSendRes {
  code: number
  msg: string
  result: null
}

export enum BizType {
  /** 手机号登录 */
  PhoneLogin = 1,
  /** 找回密码 */
  FindPassword = 2,
  /** 注册账户 */
  RegisterAccount = 3,
  /** 添加紧急联系人 */
  EmergencyContact = 4,
}

/* 发送短信验证码 */
export function postCodeSmsSendAPI(data: postCodeSmsSendData) {
  return axiosInstance.post
  <null, AxiosResponseData<postCodeSmsSendRes>, postCodeSmsSendData>
  ('/code/sms/send', data)
}

interface postCodeGraphicCheckData {
  bizType: BizType
  phone: string
  verifyCode: string
}

/* 校验图形验证码 */
export function postCodeGraphicCheckAPI(data: postCodeGraphicCheckData) {
  return axiosInstance.post
  <null, AxiosResponseData<postCodeSmsSendRes>, postCodeGraphicCheckData>
  ('/code/graphic/check', data)
}