<template>

  <div class="app-container calendar-list-container">
    <!-- <div class="createPost-container">
      <el-form class="form-container" :model="postForm" ref="postForm">

        <div class="createPost-main-container">
          <el-row>
            <el-col :span="21">
              <div class="postInfo-container">
                <el-row>
                  <el-col :span="6">
                    <!-- <el-form-item label-width="130px" label="请输入订单号:" class="postInfo-container-item">
                      <el-input v-model="postForm.orderid" style="width:160px" type="number">
                      </el-input>
                    </el-form-item> 
                    
                    <el-form-item label-width="130px" label="请输入玩家ID:" class="postInfo-container-item">
                      <el-input v-model="postForm.fuid" style="width:160px" type="number">
                      </el-input>
                    </el-form-item>
                    <el-form-item label-width="130px" label="" class="postInfo-container-item">
                    		<el-button  type="warning" @click="getList">搜索</el-button>
                    </el-form-item>
                  </el-col>
                </el-row>
              </div>
            </el-col>
          </el-row>
        </div>
      </el-form>
    </div>-->


    <el-table :data="list" v-loading.body="listLoading" border fit highlight-current-row style="width: 100%">

      <el-table-column align="center" label="提现订单ID" width="center">
        <template slot-scope="scope">
          <span>{{scope.row._id}}</span>
        </template>
      </el-table-column>
      <el-table-column align="center" label="uid" width="center">
        <template slot-scope="scope">
          <span>{{scope.row.uid}}</span>
        </template>
      </el-table-column>
      <el-table-column align="center" label="玩家名字" width="center">
        <template slot-scope="scope">
          <span>{{scope.row.name || ''}}</span>
        </template>
      </el-table-column>
       <!--<el-table-column align="center" label="积分" width="center">
        <template slot-scope="scope">
          <span>{{scope.row.coin || 0}}</span>
        </template>
      </el-table-column>-->
      <el-table-column align="center" label="提现数量" width="center">
        <template slot-scope="scope">
          <span>{{scope.row.count || 0}}</span>
        </template>
      </el-table-column>
      <el-table-column align="center" label="手机号" width="center">
        <template slot-scope="scope">
          <span>{{scope.row.phone || '' }}</span>
        </template>
      </el-table-column>
      <el-table-column align="center" label="支付宝" width="center">
        <template slot-scope="scope">
          <span>{{scope.row.zhifubao || '' }}</span>
        </template>
      </el-table-column>
      
      <el-table-column align="center" label="状态" width="center">
        <template slot-scope="scope">
        	  <span :class="scope.row.status == 1? nor:(scope.row.status == 0? tg:ju)">{{getstatustext(scope.row.status) }}</span>
          <!--<span>{{scope.row.status }}</span>-->
        </template>
      </el-table-column>
      <!--<el-table-column align="center" label="钱包" width="center">
		<template slot-scope="scope">
        	  <span :class="scope.row.type == 'ethwallet'? eth: wal">{{ scope.row.tixianwallet }}</span>
        	  <!--ethwallet  wallet-->
          <!--<span>{{scope.row.status }}</span>
        </template>
      </el-table-column>-->
      
      <el-table-column align="center" label="发起时间" width="center">
        <template slot-scope="scope">
          <span>{{ getTime(parseInt(scope.row.time)) }}</span>
        </template>
      </el-table-column>
      
       <el-table-column :width='120' align="center" label="操作1">
        <template slot-scope="scope">
          <div v-if="scope.row.status==1">
          <el-button  type="success"  @click="allowtixian(scope.row._id)">批准提现</el-button>          
          </div>
          <div v-else>
          <el-button  v-bind:disabled="true" type="success"  @click="allowtixian(scope.row._id)">批准提现</el-button>          
          </div>
        </template>
      </el-table-column>
      
      <el-table-column :width='120' align="center" label="操作2">
        <template slot-scope="scope">
          <div v-if="scope.row.status==1">
          <el-button  type="danger"  @click="decltixian(scope.row._id)">拒绝提现</el-button>          
          </div>
          <div v-else>
          <el-button v-bind:disabled="true" type="danger"  @click="decltixian(scope.row._id)">拒绝提现</el-button>          
          </div>
        </template>
      </el-table-column>
     
      
      <!--<el-table-column align="center" label="操作时间" width="center">
        <template slot-scope="scope">
          <span>{{getTime(parseInt(scope.row.optime)) }}</span>
        </template>
      </el-table-column>-->

<!--      <el-table-column align="center" label="操作员" width="center">
        <template slot-scope="scope">
          <span>{{ scope.row.opadmin }}</span>
        </template>
      </el-table-column>
 -->
 
      <!--<el-table-column min-width="100px" align="center" label="操作2">
        <template slot-scope="scope">
          <el-button  type="danger"  @click="decltixian(scope.row._id)">拒绝提现</el-button>          
        </template>
      </el-table-column>-->

    </el-table>
    <div v-show="!listLoading" class="pagination-container">
      <el-pagination background @size-change="handleSizeChange" @current-change="handleCurrentChange" :current-page.sync="listQuery.page"
                     :page-sizes="[10,20,30, 50]" :page-size="listQuery.limit" layout="total, sizes, prev, pager, next, jumper" :total="total">
      </el-pagination>
    </div>
  </div>


</template>

<script>
  import { querytixian, allowtibi, decltibi } from '@/api/info'
  const defaultForm = {
    uid: '',
    start_time: undefined,
    end_time: undefined
  }

  export default {
    name: 'inlineEditTable',
    data() {
      return {
      	eth:'eth',
      	wal:'wal',
      	nor:'nor',
      	ju:'ju',
      	tg:'tg',
        postForm: Object.assign({}, defaultForm),
        list: null,
        listquan: null,
        listLoading: false,
        total: null,
        orderid: '',
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
      this.getList()
    },
    methods: {
      getList() {
        this.listLoading = true
        querytixian(this.postForm.orderid, this.postForm.fuid).then(response => {
          console.log(JSON.stringify(response))

          if (JSON.stringify(response.data) == "{}"){
            this.listquan = []
          } else {
            this.listquan = response.data
          }
          this.total = response.data.length
          this.list = this.listquan.slice(0, this.listQuery.limit)
          this.listLoading = false
        }).catch(() => {
          this.listLoading = false
        })
      },
      allowtixian(orderid){
      	this.listLoading = true
      	allowtibi(orderid,this.uid).then(response => {
          console.log(JSON.stringify(response))
          this.getList()
          this.listLoading = false
        }).catch(() => {
          this.listLoading = false
        })
      },
      decltixian(orderid){
      	this.listLoading = true
      	decltibi(orderid,this.uid).then(response => {
          console.log(JSON.stringify(response))
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
      getstatustext(status){
      	var text = '已提现'
      	status = parseInt(status)
      	if(status == 1){
      		text = '待操作'
      	}else if(status == 2){
  			text = '已拒绝'
  		}
  		return text;
      },
      getTime(timeStamp) {
      	if(isNaN(timeStamp) == true){
      		return ''
      	}
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
        var d = new Date(this.postForm.start_time)
        var youWant = d.getFullYear() + '-' + (d.getMonth() + 1) + '-' + d.getDate() + ' ' + d.getHours() + ':' + d.getMinutes() + ':' + d.getSeconds();
        var begin = Date.parse(new Date(youWant))
        begin = begin / 1000
        var d1 = new Date(this.postForm.end_time)
        var youWant1 = d1.getFullYear() + '-' + (d1.getMonth() + 1) + '-' + d1.getDate() + ' ' + d1.getHours() + ':' + d1.getMinutes() + ':' + d1.getSeconds();
        var end = Date.parse(new Date(youWant1))
        end = end / 1000
        this.start = begin
        this.end = end
        this.getList()
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
  .tg{
  	color: darkgreen;
  	font-size: larger;
  	font-style: oblique;
  	background-color:darkgray
  }
  .ju{
  	color: red;
  	font-size: medium;
  	/*font-style: italic;*/
  	/*background-color:darkgray*/
  }
  .nor{
  	color: black;
  }  
  .eth{
  	font-size: larger;
  	color: blue;
  }
  .wal{
  	font-size: larger;
  	color: red;
  }
</style>
