<template>
  <div class="app-container calendar-list-container">

    <div class="createPost-container">
      <el-form class="form-container" :model="postForm" ref="postForm">

        <div class="createPost-main-container">
          <el-row>
            <el-col :span="21">
              <div class="postInfo-container">
                <el-row>
                  <!--<el-col :span="6">
                  </el-col>-->
				<el-form-item label-width="130px" label="标题:" class="postInfo-container-item">
                      <el-input v-model="postForm.title"></el-input>
                    </el-form-item>
                    <el-form-item label-width="130px" label="公告内容:" class="postInfo-container-item">
                      <el-input type="textarea" v-model="postForm.content">
                      </el-input>
                    </el-form-item>	
                    <el-form-item label-width="130px" label="" class="postInfo-container-item">
                        <el-button  type="warning" @click="onSubmit" style="width:30%  margin-left: 30px">立即添加</el-button>
                    </el-form-item>	
                </el-row>
              </div>
            </el-col>

          </el-row>

        </div>
      </el-form>

    </div>


    <el-table :data="list" v-loading.body="listLoading" border fit highlight-current-row style="width: 100%">


      <el-table-column align="center" label="ID号" width="center">
        <template slot-scope="scope">
          <span>{{parseInt(scope.row._id)}}</span>
        </template>
      </el-table-column>

      <el-table-column align="center" label="标题" width="center">
        <template slot-scope="scope">
          <span>{{scope.row.title}}</span>
        </template>
      </el-table-column>

      <el-table-column align="center" label="内容" width="center">
        <template slot-scope="scope">
          <span>{{scope.row.content}}</span>
        </template>
      </el-table-column>
      
      <el-table-column min-width="100px" align="center" label="时间">
        <template slot-scope="scope">
          <span>{{getTime(scope.row.time)}}</span>
        </template>
      </el-table-column>
<!-- 		<el-table-column min-width="100px" align="center" label="操作">
	        <template slot-scope="scope">
	          <el-button  type="success"  @click="delwenti(scope.row._id)">删除</el-button>          
	        </template>
	      </el-table-column> -->

    </el-table>
    <div v-show="!listLoading" class="pagination-container">
      <el-pagination background @size-change="handleSizeChange" @current-change="handleCurrentChange" :current-page.sync="listQuery.page"
                     :page-sizes="[10,20,30, 50]" :page-size="listQuery.limit" layout="total, sizes, prev, pager, next, jumper" :total="total">
      </el-pagination>
    </div>
  </div>


</template>

<script>
  import { setchangjian, getchangjian,delchangjian } from '@/api/setting'
  const defaultForm = {
    uid: '',
  }

  export default {
    name: 'inlineEditTable',
    data() {
      return {
        postForm: Object.assign({}, defaultForm),
        list: null,
        listquan: null,
        listLoading: true,
        total: null,
        uid: localStorage.getItem("username"),
        listQuery: {
          page: 1,
          limit: 10
        },
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
        getchangjian().then(response => {
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
      },
      delwenti(id){
      	this.listLoading = true
        delchangjian(id).then(response => {
          console.log(JSON.stringify(response))
          this.listLoading = false
          if(response.code == 20000){
        		 	this.getList()
        	  }
        }).catch(() => {
          this.listLoading = false
        })
      },
      onSubmit() {
        this.listLoading = true
//      var content = this.postForm.content
//      if(content.length > 200){
//      		alert("内容限制300字")
//      		return;
//      }
        setchangjian(this.postForm).then(response => {
        		 console.log(JSON.stringify(response))
        		 if(response.code == 20000){
        		 	this.getList()
        		 }
          this.handleModifyStatus()
          this.listLoading = false
        }).catch(() => {
          this.listLoading = false
        })
      },
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
</style>
