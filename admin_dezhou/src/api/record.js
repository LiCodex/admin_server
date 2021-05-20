import request from '@/utils/request'

export function usdtrecord_uid(uid) {
	console.log('________usdtrecord_uid_____uid:' + uid)
    return request({
	    url: process.env.BASE_API + '/usdtchongzhijilv?fuid=' + uid,
	    method: 'get'
	  })
}

export function tbkrecord_uid(uid) {
	console.log('________tbkrecord_uid_____uid:' + uid)
    return request({
	    url: process.env.BASE_API + '/tbkchongzhijilv?fuid=' + uid,
	    method: 'get'
	  })
}


export function chongzhirecord(uid) {
	console.log('________tbkrecord_uid_____uid:' + uid)
    return request({
	    url: process.env.BASE_API + '/getchongzhirecord?fuid=' + uid,
	    method: 'get'
	  })
}


export function tbkrecord_calc_uid(uid) {
	console.log('________tbkrecord_uid_____uid:' + uid)
    return request({
	    url: process.env.BASE_API + '/calctbkjilv?fuid=' + uid + "&tp=1",
	    method: 'get'
	  })
}


export function tixianjilu(uid) {
	console.log('________tixianjilu_____uid:' + uid)
    return request({
	    url: process.env.BASE_API + '/tixianjilv?fuid=' + uid,
	    method: 'get'
	  })
}


export function yinglijilu(uid) {
	console.log('________yinglijilu_____uid:' + uid)
    return request({
	    url: process.env.BASE_API + '/yinglijilv?fuid=' + uid+ "&tp=111",
	    method: 'get'
	  })
}

export function fanlijilu(uid) {
	console.log('_______fanlijilu_____uid:' + uid)
    return request({
	    url: process.env.BASE_API + '/gamefanli?fuid=' + uid+ "&tp=112",
	    method: 'get'
	  })
}


export function getlunpanrecord(st,et,uid) {
	console.log('________getlunpanrecord_____uid:' + uid)
	if(isNaN(st) == true || st == 0){
		st = ''
	}
	if(isNaN(et) == true || et == 0){
		et = ''
	}
	if(uid == null){
		uid = ''
	}
    return request({
	    url: process.env.BASE_API + '/getlunpanrecord?fuid=' + uid+ "&st=" + st + "&et=" + et,
	    method: 'get'
	  })
}
