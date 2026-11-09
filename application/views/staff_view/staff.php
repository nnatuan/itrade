<div class="right_col" role="main">
    <div class="">
        <div class="clearfix"></div>
        <div class="row">
            <div class="col-md-12 col-sm-12">
                <div class="x_panel qcare-form-panel">
                    <div class="x_title">
                        <h2><i class="fa fa-users"></i> <?php echo $lbl_form_title; ?></h2> 
                        <div class="clearfix"></div>
                    </div>
                    <div class="x_content">
                        <br />
                        <?php if($m_message != ''): ?>
                            <div class="alert alert-danger"><strong>Thông báo lỗi:</strong> <?php echo $m_message; ?></div>
                        <?php endif; ?>

                        <form name="form_main" method="post" action="<?php echo $link_page; ?>" class="form-horizontal form-label-left">
                            
                            <h5 class="qcare-form-section-title section-blue">I. THÔNG TIN QUẢN TRỊ TÀI KHOẢN</h5>
                            
                            <div class="item form-group">
                                <label class="col-form-label col-md-2 col-sm-2 label-align">Tên đăng nhập <span class="required">*</span></label>
                                <div class="col-md-8 col-sm-8">
                                    <input type="text" name="txt_cuserid" value="<?php echo $txt_cuserid; ?>" required="required" class="form-control" <?php echo ($event == 'edit') ? 'readonly style="background:#eee;"' : ''; ?> placeholder="Ví dụ: sale_hoang" oninput="this.value = this.value.toLowerCase().replace(/[^a-z0-9_]/g, '');">
                                </div>
                            </div>

                            <div class="item form-group">
                                <label class="col-form-label col-md-2 col-sm-2 label-align">Mật khẩu truy cập <?php echo ($event == 'add') ? '<span class="required">*</span>' : ''; ?></label>
                                <div class="col-md-8 col-sm-8">
                                    <input type="password" name="txt_cpassword" class="form-control" placeholder="<?php echo ($event == 'edit') ? 'Bỏ trống nếu giữ nguyên mật khẩu cũ' : 'Nhập mật khẩu truy cập'; ?>" <?php echo ($event == 'add') ? 'required="required"' : ''; ?>>
                                </div>
                            </div>

                            <div class="item form-group">
                                <label class="col-form-label col-md-2 col-sm-2 label-align">Phân quyền vai trò</label>
                                <div class="col-md-3 col-sm-3">
                                    <select name="cbof_crole" class="form-control">
                                        <option value="sale" <?php echo ($cbof_crole == 'sale') ? 'selected' : ''; ?>>Sale (Nhân viên kinh doanh / Đại lý)</option>
                                        <option value="admin" <?php echo ($cbof_crole == 'admin') ? 'selected' : ''; ?>>Admin (Quản trị viên tối cao)</option>
                                    </select>
                                </div>
                                <label class="col-form-label col-md-2 col-sm-2 label-align">Trạng thái khóa</label>
                                <div class="col-md-3 col-sm-3">
                                    <select name="cbof_cstatus" class="form-control">
                                        <option value="1" <?php echo ($cbof_cstatus == '1') ? 'selected' : ''; ?>>1: Cho phép hoạt động</option>
                                        <option value="0" <?php echo ($cbof_cstatus == '0') ? 'selected' : ''; ?>>0: Tạm khóa tài khoản</option>
                                    </select>
                                </div>
                            </div>

                            <h5 class="qcare-form-section-title section-teal">II. THÔNG TIN HỒ SƠ LÝ LỊCH CÁ NHÂN</h5>

                            <div class="item form-group">
                                <label class="col-form-label col-md-2 col-sm-2 label-align">Họ và Tên <span class="required">*</span></label>
                                <div class="col-md-8 col-sm-8">
                                    <input type="text" name="txt_cfullname" value="<?php echo $txt_cfullname; ?>" required="required" class="form-control" placeholder="Nhập đầy đủ Họ tên">
                                </div>
                            </div>

                            <div class="item form-group">
                                <label class="col-form-label col-md-2 col-sm-2 label-align">Số điện thoại</label>
                                <div class="col-md-3 col-sm-3">
                                    <input type="text" name="txt_chandphone" value="<?php echo $txt_chandphone; ?>" class="form-control" placeholder="Nhập số di động" maxlength="11" oninput="this.value = this.value.replace(/[^0-9]/g, '');">
                                </div>
                                <label class="col-form-label col-md-2 col-sm-2 label-align">Email</label>
                                <div class="col-md-3 col-sm-3">
                                    <input type="email" name="txt_cemail" value="<?php echo $txt_cemail; ?>" class="form-control" placeholder="Nhập địa chỉ email">
                                </div>
                            </div>

                            <div class="item form-group">
                                <label class="col-form-label col-md-2 col-sm-2 label-align">Giới tính</label>
                                <div class="col-md-3 col-sm-3">
                                    <select name="cbof_cgender" class="form-control">
                                        <option value="Nam" <?php echo ($cbof_cgender == 'Nam') ? 'selected' : ''; ?>>Nam</option>
                                        <option value="Nữ" <?php echo ($cbof_cgender == 'Nữ') ? 'selected' : ''; ?>>Nữ</option>
                                    </select>
                                </div>
                                <label class="col-form-label col-md-2 col-sm-2 label-align">Ngày sinh</label>
                                <div class="col-md-3 col-sm-3">
                                    <input type="date" name="txt_dbirthday" value="<?php echo $txt_dbirthday; ?>" class="form-control">
                                </div>
                            </div>

                            <div class="ln_solid"></div>
                            <div class="item form-group">
                                <div class="col-md-8 col-sm-8 offset-md-2">
                                    <button type="button" class="btn btn-success qcare-form-btn" name="btn_submit" value="btn_submit" onclick="js_SetSubmitButtonClick(this.form, this.name);"><i class="fa fa-save"></i> Lưu thông tin tài khoản</button>
                                    <button class="btn btn-secondary qcare-form-btn" type="button" onclick="location.href='<?php echo $link_cancel; ?>'"><i class="fa fa-chevron-left"></i> Quay về</button>
                                </div>
                            </div>

                            <input name="hidden_nid" type="hidden" value="<?php echo $nid; ?>" />
                            <input name="hidden_event" type="hidden" value="<?php echo $event; ?>" />
                            <input type="hidden" name="hidden_button" value="" />
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>