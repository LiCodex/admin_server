import request from '@/utils/request'

export function createroom(form,uid) {
	if(form.time == null || form.chaircount == null || form.mincoin == null || form.maxcoin == null
		|| form.shangfen == null || form.damang == null || form.xiaomang == null || form.tp == null
	 || form.name == null || form.size == null ){
		return
	}
	var param = 'name='+form.name+"&size="+form.size+"&time="+form.time+"&chaircount="+form.chaircount+"&mincoin="+form.mincoin
		+ "&maxcoin="+form.maxcoin+"&shangfen="+form.shangfen+"&damang="+form.damang+"&xiaomang="+form.xiaomang+"&tp="+form.tp

  return request({
    url: process.env.BASE_API_GONGNENG + '/api/createroom?' + param ,
    method: 'get'
  })
}


export function getplayers(page) {
  return request({
    url: process.env.BASE_API_GONGNENG + '/api/getalluserlist?page=' + page+"&limit=500" ,
    method: 'get'
  })
}

export function api_setfenghao(uid) {
  return request({
    url: process.env.BASE_API_GONGNENG + '/api/setstatus?uid=' + uid ,
    method: 'get'
  })
}

export function setcoin(form) {
	var uid = form.uid
	var count = form.count
  return request({
    url: process.env.BASE_API_GONGNENG + '/api/setcoin?uid=' + uid + "&num=" + count ,
    method: 'get'
  })
}

export function jiluchongzhi(uid,count) {
  return request({
    url: process.env.BASE_API + '/jiluchongzhi?chongzhiuid=' + uid + "&count=" + count ,
    method: 'get'
  })
}

export function getadminroomlist(size) {
  return request({
    url: process.env.BASE_API_GONGNENG + '/api/getadminroomlist?size=' + size,
    method: 'get'
  })
}
