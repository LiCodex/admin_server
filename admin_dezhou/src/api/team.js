import request from '@/utils/request'

export function getteaminfo() {
  return request({
    url: process.env.BASE_API + '/getteaminfo',
	method: 'get'
  })
}

export function getlevel_list(data) {
	console.log('data:' + JSON.stringify(data))
  return request({
    url: process.env.BASE_API + '/getlevel_list?level='+ data,
	method: 'get'
  })
}


export function getteamdetail(uid, lvl) {
	console.log('data:' + JSON.stringify(uid))
	var lev = parseInt(lvl)
	if(isNaN(lev) == true){
		return request({
		    url: process.env.BASE_API + '/getteamdetail?fuid='+ uid + "&level=" + lvl,
			method: 'get'
		  })
	}else{
		return request({
		    url: process.env.BASE_API + '/getteamdetailbylvl?fuid='+ uid + "&level=" + lvl,
			method: 'get'
		  })
	}
}

export function teamfenghaobylevel(uid,lvl,fenghao) {
	console.log('data:' + JSON.stringify(uid))
	var lev = parseInt(lvl)
	if(isNaN(lev) == true){
		lev = 5
	}
	var fh = parseInt(fenghao)
	if(isNaN(fh) == true){
		fh = 1	// 默认封号
	}

	return request({
	    url: process.env.BASE_API + '/fenghaoteamlvl?fuid='+ uid + "&level=" + lvl + "&fenghao=" + fh ,
		method: 'get'
	  })
}
