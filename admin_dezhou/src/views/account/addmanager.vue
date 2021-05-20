<template>
  <div class="createPost-container">
    <el-form ref="form" :model="form" label-width="180px">

      <el-form-item label="管理员名字:">
        <el-input v-model="form.name"></el-input>
      </el-form-item>
      
      <el-form-item label="管理员密码:">
        <el-input v-model="form.password"></el-input>
      </el-form-item>
      
      <el-form-item label="管理员权限:">
	      <template>
		  <el-select v-model="form.role" placeholder="请选择">
		    <el-option
		      v-for="item in options"
		      :key="item.value"
		      :label="item.label"
		      :value="item.value">
		    </el-option>
		  </el-select>
		</template>
      </el-form-item>
      
      <el-form-item>
        <el-button type="primary" @click="onSubmit">添加管理员</el-button>
      </el-form-item>
    </el-form>
  </div>
</template>

<script>
  import { addmanager } from '@/api/manager'
  export default {
    data() {
      return {
        listLoading: true,
        options: [{
          value: '1',
          label: '查看员'
        }, {
          value: '2',
          label: '管理员'
        }],
        form: {
         	name: '',
          password: '',
          role: '',
        }
      }
    },
    methods: {
      handleModifyStatus() {
        this.$message({
          message: '操作成功',
          type: 'success'
        })
      },
      onSubmit() {
        this.listLoading = true
        var str = {}
        for (var k in this.form) {
          if (this.form[k] != '') {
          	if(k == 'name' || k == 'role'){
          		str['f'+k] = this.form[k]
          	}else{
          		str[k] = this.form[k]
          	}
          }
        }
        
        var obj = this.obj_contact(str)
        
        addmanager(obj).then(response => {
        		console.log(response)
			this.handleModifyStatus()
			this.listLoading = false
        }).catch(() => {
          this.listLoading = false
        })
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
