<template>


  <div class="app-container calendar-list-container">

    <div class="createPost-container">
      <el-form class="form-container" :model="postForm" ref="postForm">

        <div class="createPost-main-container">
          <el-row>
            <el-col :span="21">
              <div class="postInfo-container">
                <el-row>
                  <el-col :span="5">
                    <el-form-item label-width="80px" label="玩家ID" class="postInfo-container-item">
                      <el-input v-model="postForm.uid" type="number"  placeholder="请输入玩家ID" style="width: 150px">
                      </el-input>
                    </el-form-item>
                  </el-col>
                  <el-button  type="warning" @click="draftForm" style="margin-left: 180px">搜索</el-button>
                </el-row>
              </div>
            </el-col>
          </el-row>
        </div>
      </el-form>

    </div>


    <el-table :data="list" v-loading.body="listLoading" border fit highlight-current-row style="width: 100%">
    	
      <el-table-column align="center" label="玩家ID">
        <template slot-scope="scope">
          <span>{{parseInt(scope.row.uid)}}</span>
        </template>
      </el-table-column>

      <el-table-column align="center" label="玩家昵称">
        <template slot-scope="scope">
          <span>{{scope.row.name}}</span>
        </template>
      </el-table-column>
      <el-table-column align="center" label="TBK">
        <template slot-scope="scope">
          <span>{{scope.row.coin}}</span>
        </template>
      </el-table-column>
      <el-table-column align="center" label="封号">
        <template slot-scope="scope">
          <span :class="scope.row.fenghao == 1?fh:mf">{{getfenghaoshowtext(scope.row.fenghao) }}</span>
        </template>
      </el-table-column>
      <el-table-column align="center" label="unionid">
        <template slot-scope="scope">
          <span>{{scope.row.unionid}}</span>
        </template>
      </el-table-column>
      <el-table-column align="center" label="性别">
        <template slot-scope="scope">
          <span>{{parseInt(scope.row.sex)==1?'女':'男'}}</span>
        </template>
      </el-table-column> 
      <el-table-column align="center" label="胜率">
        <template slot-scope="scope">
          <span>{{scope.row.shenglv || 0}}</span>
        </template>
      </el-table-column>
      <el-table-column align="center" label="usdt数量">
        <template slot-scope="scope">
          <span>{{scope.row.usdt}}</span>
        </template>
      </el-table-column>
      <el-table-column align="center" label="特殊号">
        <template slot-scope="scope">
          <span>{{parseInt(scope.row.teshu)}}</span>
        </template>
      </el-table-column>
      <el-table-column align="center" label="累计算力值">
        <template slot-scope="scope">
          <span>{{scope.row.totalreqtbk}}</span>
        </template>
      </el-table-column>
      <el-table-column align="center" label="直推">
        <template slot-scope="scope">
          <span>{{scope.row.zhitui || 0}}</span>
        </template>
      </el-table-column>
      <el-table-column align="center" label="团队">
        <template slot-scope="scope">
          <span>{{scope.row.tuandui || 0}}</span>
        </template>
      </el-table-column>
      
      <el-table-column align="center" label="支付宝">
        <template slot-scope="scope">
          <span>{{scope.row.zhifubao}}</span>
        </template>
      </el-table-column>
      <el-table-column align="center" label="真名">
        <template slot-scope="scope">
          <span>{{scope.row.realname}}</span>
        </template>
      </el-table-column>
      <el-table-column align="center" label="电话">
        <template slot-scope="scope">
          <span>{{scope.row.tel}}</span>
        </template>
      </el-table-column>
      <el-table-column align="center" label="微信">
        <template slot-scope="scope">
          <span>{{scope.row.weixin}}</span>
        </template>
      </el-table-column>
      <el-table-column align="center" label="身份证">
        <template slot-scope="scope">
          <span>{{scope.row.shenfenzheng}}</span>
        </template>
      </el-table-column>
      <el-table-column align="center" label="银行卡">
        <template slot-scope="scope">
          <span>{{scope.row.yinhangka}}</span>
        </template>
      </el-table-column>
      
      <el-table-column align="center" label="微信二维码">
        <template slot-scope="scope">
        	<img :width="60" :height="60" :src="scope.row.wxmoneyimg">
        </template>
      </el-table-column>
      <el-table-column align="center" label="支付宝二给码">
        <template slot-scope="scope">
        		<img :width="60" :height="60" :src="scope.row.zfbmoneyimg">
        </template>
      </el-table-column>
      
      
      <el-table-column align="center" label="注册时间">
        <template slot-scope="scope">
          <span>{{getTime(parseInt(scope.row.create))}}</span>
        </template>
      </el-table-column>
      
      <el-table-column align="center" label="usdt钱包地址">
        <template slot-scope="scope">
          <span>{{scope.row.wallet || ''}}</span>
        </template>
      </el-table-column>

      
      <el-table-column align="center" label="以太坊钱包地址">
        <template slot-scope="scope">
          <span>{{scope.row.ethwallet || ''}}</span>
        </template>
      </el-table-column>
      <el-table-column align="center" label="操作管理员">
        <template slot-scope="scope">
          <span>{{scope.row.opadmin || '' }}</span>
        </template>
      </el-table-column>


      <el-table-column min-width="100px" align="center" label="修改玩家信息">
        <template slot-scope="scope">
          <el-button  type="success"  @click="dialogFormVisible = true,temp.uid=scope.row.uid,temp.wallet = scope.row.wallet,temp.yinhangka = scope.row.yinhangka,temp.zhifubao = scope.row.zhifubao,temp.name = scope.row.name,temp.sex = scope.row.sex,temp.unionid = scope.row.unionid,temp.realname = scope.row.realname,temp.tel = scope.row.tel,temp.weixin = scope.row.weixin,temp.shenfenzheng = scope.row.shenfenzheng">修改玩家信息</el-button>          
        </template>
      </el-table-column>
      
    </el-table>
    <div v-show="!listLoading" class="pagination-container">
      <el-pagination background @size-change="handleSizeChange" @current-change="handleCurrentChange" :current-page.sync="listQuery.page"
                     :page-sizes="[10,20,30, 50]" :page-size="listQuery.limit" layout="total, sizes, prev, pager, next, jumper" :total="total">
      </el-pagination>
    </div>
    
    	<el-dialog :title="textMap" :visible.sync="dialogFormVisible">
      <el-form :model="temp" label-position="left" label-width="70px" style='width: 350px; margin-left:50px;'>
       <!--<el-form-item label-width="100px" label="玩家uid:" class="postInfo-container-item">
          <el-input type="text" v-model="temp.uid" readonly disabled="true">
          </el-input>
        </el-form-item>-->
        
        <el-form-item label-width="100px" label="玩家昵称:" class="postInfo-container-item">
          <el-input type="text" v-model="temp.name">
          </el-input>
        </el-form-item>
        <el-form-item label-width="100px" label="性别:" class="postInfo-container-item">
          <!--<el-input type="text" v-model="temp.sex">
          </el-input>-->
          <template>
		  <el-select v-model="temp.sex" placeholder="请选择">
		    <el-option
		      v-for="item in sexs"
		      :key="item.value"
		      :label="item.label"
		      :value="item.value">
		    </el-option>
		  </el-select>
		</template>
		</el-form-item>
		
		<el-form-item label-width="100px" label="特殊号:" class="postInfo-container-item">
          <!--<el-input type="text" v-model="temp.sex">
          </el-input>-->
          <template>
		  <el-select v-model="temp.teshu" placeholder="请选择">
		    <el-option
		      v-for="item in teshu"
		      :key="item.value"
		      :label="item.label"
		      :value="item.value">
		    </el-option>
		  </el-select>
		</template>
        </el-form-item>
        
        <el-form-item label-width="100px" label="封禁:" class="postInfo-container-item">
          <!--<el-input type="text" v-model="temp.sex">
          </el-input>-->
          <template>
		  <el-select v-model="temp.fenghao" placeholder="请选择">
		    <el-option
		      v-for="item in fenghaos"
		      :key="item.value"
		      :label="item.label"
		      :value="item.value">
		    </el-option>
		  </el-select>
		</template>
        </el-form-item>
        
        	<el-form-item label-width="100px" label="胜率:" class="postInfo-container-item">
          <el-input type="number" v-model="temp.shenglv">
          </el-input>
        </el-form-item>
        <el-form-item label-width="100px" label="unionid:" class="postInfo-container-item">
          <el-input type="text" v-model="temp.unionid">
          </el-input>
        </el-form-item>
        <el-form-item label-width="100px" label="usdt钱包地址:" class="postInfo-container-item">
          <el-input type="text" v-model="temp.wallet">
          </el-input>
        </el-form-item>
        <el-form-item label-width="100px" label="以太坊钱包地址:" class="postInfo-container-item">
          <el-input type="text" v-model="temp.ethwallet">
          </el-input>
        </el-form-item>
        <el-form-item label-width="100px" label="真实性名:" class="postInfo-container-item">
          <el-input type="text" v-model="temp.realname">
          </el-input>
        </el-form-item>
        <el-form-item label-width="100px" label="电话:" class="postInfo-container-item">
          <el-input type="text" v-model="temp.tel">
          </el-input>
        </el-form-item>
        <el-form-item label-width="100px" label="微信:" class="postInfo-container-item">
          <el-input type="text" v-model="temp.weixin">
          </el-input>
        </el-form-item>
        <el-form-item label-width="100px" label="支付宝:" class="postInfo-container-item">
          <el-input type="text" v-model="temp.zhifubao">
          </el-input>
        </el-form-item>
        <el-form-item label-width="100px" label="身份证:" class="postInfo-container-item">
          <el-input type="text" v-model="temp.shenfenzheng">
          </el-input>
        </el-form-item>
        <el-form-item label-width="100px" label="银行卡号:" class="postInfo-container-item">
          <el-input type="text" v-model="temp.yinhangka">
          </el-input>
        </el-form-item>
        
        
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button @click="dialogFormVisible = false">取消</el-button>

        <el-button type="primary" @click="modifyplayerinfo(temp)">确定</el-button>
      </div>
    </el-dialog>
    
  </div>
</template>

<script>
  import { getplayers ,findplayer,modifyplayerinf } from '@/api/players'
  const defaultForm = {
    uid: '',
    start_time: undefined, // 前台展示时间
    end_time: undefined // 前台展示时间
  }

  export default {
    name: 'inlineEditTable',
    data() {
      return {
      	fh:'fenghao',
      	mf:'mfenghao',
      	textMap: '修改玩家信息',
      	dialogFormVisible: false,
        dialogStatus: '',        
        sexs: [{
          value: 0,
          label: '男'
        }, {
          value: 1,
          label: '女'
        }],
        teshu: [{
          value: 0,
          label: '普通号'
        }, {
          value: 1,
          label: '特殊号'
        }],
       fenghaos: [{
          value: 0,
          label: '不封禁'
        }, {
          value: 1,
          label: '封禁'
        }],
        temp:{
        		uid:'',
        		name:'',
        		sex:'',
        		teshu:'',
        		fenghao:'',
        		shenglv:'',
        		unionid:'',
        		realname:'',
        		tel:'',
        		weixin:'',
        		shenfenzheng:'',
        		wallet:'',
        		yinhangka:'',
        		zhifubao:'',
        		wxmoneyimg:'',
        		zfbmoneyimg:'',
            ethwallet:'',
            opadmin:"",
        },
        postForm: Object.assign({}, defaultForm),
        list: null,
        listquan: null,
        listLoading: false,
        total: null,
        uid: localStorage.getItem("username"),
        listQuery: {
          page: 1,
          limit: 10
        },
        start: null,
        end: null
      }
    },
    filters: {
      statusFilter(status) {
        const statusMap = {
          published: 'success',
          draft: 'info',
          deleted: 'danger'
        }
        return statusMap[status]
      }
    },
    created() {
//    this.getList()
    },
    methods: {
      getList() {
        this.listLoading = true
        getplayers(this.postForm.uid).then(response => {
          console.log(response.data)
          this.listquan = response.data
          this.total = response.data.length
          this.list = this.listquan.slice(0, this.listQuery.limit)
          this.listLoading = false
        }).catch(() => {
          this.listLoading = false
        })
      },
      handleModifyStatus() {
        this.$message({
          message: '操作成功',
          type: 'success'
        })
      },
      modifyplayerinfo(form) {
        this.listLoading = true
        console.log(form)
        var str = {}
        for (var k in form) {
//        if (form[k] != '') {
		  if(true){
          	if(k=='uid' || k == 'name'){
          		str['f'+k] = form[k]
          	}else{
          		str[k] = ''+form[k]
          	}
          }
        }
        var opadminname = localStorage.getItem("username")
        str['opadmin'] = opadminname
        console.log(str)
        var obj = this.obj_contact(str)
        console.log("obj=" + obj)
        modifyplayerinf(obj).then(response => {
          this.handleModifyStatus()
          this.getList()
          this.listLoading = false
        }).catch(() => {
          this.listLoading = false
        })
      },
      handleSizeChange(val) {
        this.listQuery.limit = val
        this.list = this.listquan.slice(0, this.listQuery.limit)
      },
      handleCurrentChange(val) {
        this.listQuery.page = val
        const begin = this.listQuery.limit * (val - 1)
        const end = this.listQuery.limit * val
        this.list = this.listquan.slice(begin, end)
      },
      getTime(timeStamp) {
        var date = new Date()
        date.setTime(timeStamp * 1000)
        var y = date.getFullYear()
        var m = date.getMonth() + 1
        m = m < 10 ? ('0' + m) : m
        var d = date.getDate()
        d = d < 10 ? ('0' + d) : d
        var h = date.getHours()
        h = h < 10 ? ('0' + h) : h
        var minute = date.getMinutes()
        var second = date.getSeconds()
        minute = minute < 10 ? ('0' + minute) : minute
        second = second < 10 ? ('0' + second) : second
        return y + '-' + m + '-' + d + ' ' + h + ':' + minute + ':' + second
      },
      cancelEdit(row) {
        row.title = row.originalTitle
        row.edit = false
        this.$message({
          message: 'The title has been restored to the original value',
          type: 'warning'
        })
      },
      confirmEdit(row) {
        row.edit = false
        row.originalTitle = row.title
        this.$message({
          message: 'The title has been edited',
          type: 'success'
        })
      },
      draftForm() {
//      this.getList()
        this.listLoading = true
        getplayers(this.postForm.uid).then(response => {
          console.log(response.data)
          this.listquan = response.data
          this.total = response.data.length
          this.list = this.listquan.slice(0, this.listQuery.limit)
          this.listLoading = false
        }).catch(() => {
          this.listLoading = false
        })
      },
      getfenghaoshowtext(fenghao){
      		var text = '未封号'
      		if(fenghao == 1){
      			text = '已封号'
      		}
      		return text;
      },
     obj_contact(obj) {
        var s = ''
        for (var k in obj) {
          var v = obj[k]
          if (s == '') {
            s += k + '=' + v
          } else {
            s += '&' + k + '=' + v
          }
        }
        return s
      }
    }
  }
</script>

<style scoped>
  .edit-input {
    padding-right: 100px;
  }
  .cancel-btn {
    position: absolute;
    right: 15px;
    top: 13px;
  }
  .fenghao{
  	color: blue;
  	font-size: larger;
  	font-style: italic;
  	background-color:red
  }
  .mfenghao{
  	color: blue;
  }
</style>
