import { axiosInstance, AxiosResponseData } from '../common/utils/http';

/** 保存联系人 */
export interface postEmergencyContactData {
  /** 联系人姓名 */
  name: string;

  /** 联系人手机号 */
  phone: string;
}

/* 保存联系人 */
export function postEmergencyContactAPI(data: postEmergencyContactData) {
  return axiosInstance.post
  <null, AxiosResponseData<null>, postEmergencyContactData>
  ('/emergency-contact', data)
}


/** 保存联系人 */
export interface getEmergencyContactResponse {
  /** 紧急联系id */
  id: number;

  /** 联系人姓名 */
  name: string;

  /** 联系人手机号 */
  phone: string;
}

/* 获取紧急联系人 */
export function getEmergencyContactAPI() {
  return axiosInstance.get
  <null, AxiosResponseData<getEmergencyContactResponse>, null>
  ('/emergency-contact')
}