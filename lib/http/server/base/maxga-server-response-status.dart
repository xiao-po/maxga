enum MaxgaServerResponseStatus {
  SUCCESS,
  TIMEOUT,


  // 服务器自定义错误
  PARAM_ERROR,
  SHOULD_LOGIN,
  AUTH_PASSWORD_ERROR,
  JWT_TIMEOUT,
  USER_NOT_EXIST,
  USERNAME_INVALID,
  PASSWORD_INVALID,
  EMAIL_INVALID,
  ACTIVE_TOKEN_OUT_OF_DATE,
  ANOTHER_ACTIVE_TOKEN_EXIST,
  RESET_EMAIL_LIMITED,
  UPDATE_VALUE_EXIST,
  UPDATE_VALUE_OUT_OF_DATE,
  OPERATION_NOT_PERMIT,
  SERVICE_FAILED,
}

const Map<MaxgaServerResponseStatus, String> MaxgaServerResponseCodeMessageMap = {
  MaxgaServerResponseStatus.TIMEOUT: "服务器超时",


  // 服务器自定义错误
  MaxgaServerResponseStatus.PARAM_ERROR: '参数错误',
  MaxgaServerResponseStatus.SHOULD_LOGIN: '需要登录',
  MaxgaServerResponseStatus.AUTH_PASSWORD_ERROR: '登录验证失败',
  MaxgaServerResponseStatus.JWT_TIMEOUT: 'jwt 已经超时',
  MaxgaServerResponseStatus.USER_NOT_EXIST: '用户不存在',
  MaxgaServerResponseStatus.USERNAME_INVALID: '用户名格式不正确',
  MaxgaServerResponseStatus.PASSWORD_INVALID: '密码格式不正确',
  MaxgaServerResponseStatus.EMAIL_INVALID: '用户名格式不正确',
  MaxgaServerResponseStatus.ACTIVE_TOKEN_OUT_OF_DATE: '验证 token 不存在',
  MaxgaServerResponseStatus.ANOTHER_ACTIVE_TOKEN_EXIST: '当前账号已经更换激活邮箱',
  MaxgaServerResponseStatus.RESET_EMAIL_LIMITED: '同一个邮箱一小时只能申请重置一次',
  MaxgaServerResponseStatus.UPDATE_VALUE_EXIST: '插入的值已经存在',
  MaxgaServerResponseStatus.UPDATE_VALUE_OUT_OF_DATE: '需要更新的对象已经过时了',
  MaxgaServerResponseStatus.OPERATION_NOT_PERMIT: '无权操作其他用户数据',
  MaxgaServerResponseStatus.SERVICE_FAILED: '业务发生故障',
};
