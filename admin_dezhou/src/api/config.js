import request from '@/utils/request'

export function setconfig(data,opadmin) {
	var d = {}
	
	d.misc = {}
	if(parseInt(data.inittbk) != null){
		d.misc.inittbk = parseInt(data.inittbk) 
	}
	if(parseInt(data.extra_cal) != null){
		d.misc.extra_cal = parseInt(data.extra_cal) 
	}
	if(parseInt(data.tbk2usdt) != null){
		d.misc.tbk2usdt = parseInt(data.tbk2usdt) 
	}
	if(parseInt(data.usdt2tbk) != null){
		d.misc.usdt2tbk = parseInt(data.usdt2tbk) 
	}
	if(parseInt(data.c2cmoney) != null){
		d.misc.c2cmoney = parseInt(data.c2cmoney) 
	}
	if(parseInt(data.tixian) != null){
		d.misc.tixian = parseInt(data.tixian) 
	}
	
	d.huizhang = {}
	d.huizhang.lvl1 = {}
	d.huizhang.lvl2 = {}
	d.huizhang.lvl3 = {}
	d.huizhang.lvl1.zhitui = data.huiz_lv1_zhitui
	d.huizhang.lvl1.tuandui = data.huiz_lv1_tuandui
	d.huizhang.lvl2.zhitui = data.huiz_lv2_zhitui
	d.huizhang.lvl2.tuandui = data.huiz_lv2_tuandui
	d.huizhang.lvl3.zhitui = data.huiz_lv3_zhitui
	d.huizhang.lvl3.tuandui = data.huiz_lv3_tuandui

	d.fanliconfig = {}
	d.fanliconfig.lvl1 = {}
	d.fanliconfig.lvl2 = {}
	d.fanliconfig.lvl3 = {}
	d.fanliconfig.lvl4 = {}
	
	d.fanliconfig.lvl1.lvl1 = data.huiz_lv1_1_sxf
	d.fanliconfig.lvl1.lvl2 = data.huiz_lv1_2_sxf
	d.fanliconfig.lvl1.lvl3 = data.huiz_lv1_3_sxf
	d.fanliconfig.lvl2.lvl1 = data.huiz_lv2_1_sxf
	d.fanliconfig.lvl2.lvl2 = data.huiz_lv2_2_sxf
	d.fanliconfig.lvl2.lvl3 = data.huiz_lv2_3_sxf
	d.fanliconfig.lvl3.lvl1 = data.huiz_lv3_1_sxf
	d.fanliconfig.lvl3.lvl2 = data.huiz_lv3_2_sxf
	d.fanliconfig.lvl3.lvl3 = data.huiz_lv3_3_sxf
	d.fanliconfig.lvl4.lvl1 = data.huiz_lv4_1_sxf
	d.fanliconfig.lvl4.lvl2 = data.huiz_lv4_2_sxf
	d.fanliconfig.lvl4.lvl3 = data.huiz_lv4_3_sxf
	d.fanliconfig.lvl4.lvl4 = data.huiz_lv4_4_sxf

	d.chongzhitbkconfig = {}
	d.chongzhitbkconfig.putong = {}
	d.chongzhitbkconfig.teshu = {}
	
	d.chongzhitbkconfig.putong.lvl1 = data.pt_cz_1_conf
	d.chongzhitbkconfig.putong.lvl2 = data.pt_cz_2_conf
	d.chongzhitbkconfig.putong.lvl3 = data.pt_cz_3_conf
	
	d.chongzhitbkconfig.teshu.lvl1 = data.ts_cz_1_conf
	d.chongzhitbkconfig.teshu.lvl2 = data.ts_cz_2_conf
	d.chongzhitbkconfig.teshu.lvl3 = data.ts_cz_3_conf
	d.chongzhitbkconfig.teshu.lvl4 = data.ts_cz_4_conf
	
	if(opadmin!= null){
		d.opadmin = opadmin
	}

	var data = 'data='+JSON.stringify(d)
	console.log(JSON.stringify(data))
	
	return request({
	    url: process.env.BASE_API + '/setnumberconfig',
	    method: 'post',
	    data: data
	})
}

export function setlunpanconfig(lunpanconf) {	
	var data = 'data='+JSON.stringify(lunpanconf)
	console.log(JSON.stringify(data))
	
	return request({
	    url: process.env.BASE_API + '/setgameconfig',
//	    url: process.env.BASE_API + '/setnumberconfig',
	    method: 'post',
	    data:data
	})
}


export function setgameconfig(form,gamename) {
	var d = {}
	d.ziyoumin = form.ziyoumin
	d.jishu = form.jishu
	
	var config = {}
	config[gamename] = {}
	config[gamename][form.index] = {}
	config[gamename][form.index] = d
	var gamelist = {}
	gamelist['gamelist'] = config
	
	var data = 'data='+JSON.stringify(gamelist)
	console.log(JSON.stringify(data))
	
	return request({
	    url: process.env.BASE_API + '/setgameconfig',
	    method: 'post',
	    data:data
	})
}


export function setfangkaconfig(form,gamename) {
	var d = {}
	d.round12 = form.round12
	d.round24 = form.round24
	d.round36 = form.round36
	
	var config = {}
	config[gamename] = {}
	config[gamename] = d
	var gamecoastcoin = {}
	gamecoastcoin['gamecoastcoin'] = config
	
	var data = 'data='+JSON.stringify(gamecoastcoin)
	console.log(JSON.stringify(data))
	
	return request({
	    url: process.env.BASE_API + '/setgameconfig',
	    method: 'post',
	    data:data
	})
}

export function getconfig() {
	return request({
	    url: process.env.BASE_API + '/getallconfig',
	    method: 'get',
	})
}

export function sethuizhang(uid,val) {
  return request({
    url: process.env.BASE_API + '/sethuizhang?uid=' + uid + '&set=' + val,
    method: 'get'
  })
}

export function setteshu(uid,val) {
  return request({
    url: process.env.BASE_API + '/setteshuaccount?uid=' + uid + '&set=' + val,
    method: 'get'
  })
}

export function enablejiaoyi(enablejiaoyi) {
	var jiaoyi = enablejiaoyi == true ? 1:0;
	var config = {}
	config['enablejiaoyi'] = {}
	config['enablejiaoyi']['kaiqi'] = jiaoyi
	var data = 'data='+JSON.stringify(config)
	console.log(JSON.stringify(data))
	
  return request({
    url: process.env.BASE_API + '/enablejiaoyiqu?'+data,
    method: 'get'
  })
}


