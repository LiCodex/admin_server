<template>


  <div class="app-container calendar-list-container">

    <div class="createPost-container">
      <el-form class="form-container" :model="postForm" ref="postForm">

        <div class="createPost-main-container">
          <el-row>
            <el-col :span="21">
              <div class="postInfo-container">
                <el-row>
                  <el-col :span="6">
                    <el-form-item label-width="130px" label="请输入玩家ID:" class="postInfo-container-item">
                      <el-input v-model="postForm.uid" type="number">
                      </el-input>
                    </el-form-item>
                  </el-col>

                  <el-button  type="warning" @click="getList" style="margin-left: 30px">搜索</el-button>
                </el-row>
                <el-row>
                  <el-col :span="6">
                    <el-form-item label-width="130px" label="搜索玩家充值总额" class="postInfo-container-item">
                      <el-input v-model="postForm.money" type="number" disabled="">
                      </el-input>
                    </el-form-item>
                  </el-col>

                </el-row>
                <el-row>
                  <el-col :span="6">
                    <el-form-item label-width="130px" label="充值总额" class="postInfo-container-item">
                      <el-input v-model="postForm.totalchongzhi" type="number" disabled="">
                      </el-input>
                    </el-form-item>
                  </el-col>

                </el-row>
              </div>
            </el-col>

          </el-row>

        </div>
      </el-form>

    </div>


    <el-table :data="list" v-loading.body="listLoading" border fit highlight-current-row style="width: 100%">


      <el-table-column align="center" label="玩家ID" width="center">
        <template slot-scope="scope">
          <span>{{parseInt(scope.row.uid)}}</span>
        </template>
      </el-table-column>

      <el-table-column align="center" label="玩家姓名" width="center">
        <template slot-scope="scope">
          <span>{{scope.row.name}}</span>
        </template>
      </el-table-column>

      <el-table-column align="center" label="充值usdt数量" width="center">
        <template slot-scope="scope">
          <span>{{scope.row.usdt}}</span>
        </template>
      </el-table-column>
      
      <!--<el-table-column align="center" label="充值后usdt数量" width="center">
        <template slot-scope="scope">
          <span>{{scope.row.usdt}}</span>
        </template>
      </el-table-column>-->
      
      <el-table-column align="center" label="钱包地址" width="center">
        <template slot-scope="scope">
          <span>{{scope.row.wallet}}</span>
        </template>
      </el-table-column>


      <el-table-column min-width="100px" align="center" label="充值时间">
        <template slot-scope="scope">
          <span>{{getTime(parseInt(scope.row.timestamp))}}</span>
        </template>
      </el-table-column>


    </el-table>
    <div v-show="!listLoading" class="pagination-container">
      <el-pagination background @size-change="handleSizeChange" @current-change="handleCurrentChange" :current-page.sync="listQuery.page"
                     :page-sizes="[10,20,30, 50]" :page-size="listQuery.limit" layout="total, sizes, prev, pager, next, jumper" :total="total">
      </el-pagination>
    </div>
  </div>


</template>

<script>
  import { getchongzhiusdtrecord } from '@/api/setting'
  const defaultForm = {
    uid: '',
    totalchongzhi: 0,
    money: 0,
    start_time: undefined,
    end_time: undefined
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
        getchongzhiusdtrecord(this.postForm.uid).then(response => {
          console.log(JSON.stringify(response))

			console.log("total chongzi: " + response.totalchongzhi )
          this.postForm.totalchongzhi = parseInt(response.totalchongzhi)
          if(response.money != null){
          	this.postForm.money = parseInt(response.money)
          }else{
          	this.postForm.money =0
          }
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
</style>
