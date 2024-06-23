/* 校验图形验证码 */
import { FaultLogger } from '@kit.PerformanceAnalysisKit';
import { axiosInstance, AxiosResponseData } from '../common/utils/http';

interface logFaultReportBatchParams {
  faults: FaultLogger.FaultLogInfo[]
}

/* 故障日志批量上传 */
export function logFaultReportBatchAPI(data: logFaultReportBatchParams) {
  return axiosInstance.post
  <null, AxiosResponseData<null>, logFaultReportBatchParams>
  ('/log/fault/report/batch', data)
}

/* 故障日志单条上传 */
export function logFaultReportSingleAPI(data: FaultLogger.FaultLogInfo) {
  return axiosInstance.post
  <null, AxiosResponseData<null>, FaultLogger.FaultLogInfo>
  ('/log/fault/report/single', data)
}
