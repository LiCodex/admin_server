import request from '@/utils/request'

export function shenqingtixian(form,uid) {
	if(uid == null || form.phonenumber == null || form.zhifubao == null || form.count == null){
		return
	}
	var param = 'uid='+uid+"&phone="+form.phonenumber+"&zhifubao="+form.zhifubao+"&count="+form.count

  return request({
    url: process.env.BASE_API + '/shenqingtixian?' + param ,
    method: 'get'
  })

}

export function gettixianjifen(uid) {
  return request({
    url: process.env.BASE_API + '/gettixianjifen?uid=' + uid ,
    method: 'get'
  })
}

export function getyejirecord(uid) {
  return request({
    url: process.env.BASE_API + '/getyejirecord?fuid=' + uid ,
    method: 'get'
  })
}

export function getfanli(uid) {
  return request({
    url: process.env.BASE_API + '/getfanli?uid=' + uid ,
    method: 'get'
  })
}

export function setfanli(form,uid) {
  return request({
    url: process.env.BASE_API + '/setfanli?uid=' + uid  + '&fanli=' + form.fanli,
    method: 'get'
  })
}


export function getadminfanli(uid) {
  return request({
    url: process.env.BASE_API + '/getadminfanli?uid=' + uid ,
    method: 'get'
  })
}

export function setadminfanli(form,uid) {
  return request({
    url: process.env.BASE_API + '/setadminfanli?uid=' + uid  + '&fanli=' + form.fanli,
    method: 'get'
  })
}
