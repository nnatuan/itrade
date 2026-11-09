<form name="frm_bot_license_history" id="frm_bot_license_history" method="post" action="<?php echo $link_page; ?>">
    <div class="right_col" role="main">
        <div class="">
            <div class="clearfix"></div>

            <div class="row">
                <div class="col-md-12 col-sm-12">
                    <div class="x_panel">
                        <div class="x_title">
                            <h2><?php echo $lbl_form_title; ?></h2>
                            <ul class="nav navbar-right panel_toolbox">
                                <li><a class="collapse-link"><i class="fa fa-chevron-up"></i></a></li>
                            </ul>
                            <div class="clearfix"></div>
                        </div>
                        <div class="x_content">
                            
                            <div class="table-responsive">
                                <table class="table table-striped table-bordered jambo_table bulk_action">
                                    <thead>
                                        <tr>
                                             <th class="qcare-th-center qcare-th-stt">#</th>
                                             <th class="qcare-th-code">Số TK MT5</th>
                                             <th>Khách hàng</th>
                                             <th class="qcare-th-center" style="width: 150px;">Mã License Key</th>
                                             <th class="qcare-th-center" style="width: 120px;">Hành động</th>
                                             <th class="qcare-th-center" style="width: 150px;">Hạn cũ trước xử lý</th>
                                             <th class="qcare-th-center" style="width: 150px;">Hạn mới kích hoạt</th>
                                             <th>Ghi chú lý do gia hạn</th>
                                             <th class="qcare-th-center">Ngày xử lý</th>
                                        </tr>
                                    </thead>
                                    <tbody>

                                        <tr class="filter qcare-filter-row">
                                            <td class="text-center">
                                                <input name="btn_filter" type="button" class="btn btn-success btn-xs qcare-btn-filter-submit" value="Lọc" 
                                                    onclick="js_SetSubmitButtonClick(this.form, this.name);" />
                                            </td>
                                            <td> 
                                                <input name="txtf_cmt5_account" type="text" class="form-control input-sm" value="<?php echo isset($txtf_cmt5_account) ? $txtf_cmt5_account : ''; ?>" placeholder="Lọc TK MT5..." />					
                                            </td>
                                            <td>
                                                <input name="txtf_cfullname" type="text" class="form-control input-sm" value="<?php echo isset($txtf_cfullname) ? $txtf_cfullname : ''; ?>" placeholder="Tìm tên khách..." />
                                            </td>
                                            <td>
                                                <input name="txtf_clicense_key" type="text" class="form-control input-sm" value="<?php echo isset($txtf_clicense_key) ? $txtf_clicense_key : ''; ?>" placeholder="Lọc Key..." />
                                            </td>
                                            <td>
                                                <select name="cbof_action_type" class="form-control input-sm" onchange="js_SetSubmitButtonClick(this.form, 'btn_filter');">
                                                    <option value="">-- Tất cả --</option>
                                                    <option value="1" <?php echo (isset($cbof_action_type) && $cbof_action_type == '1') ? 'selected' : ''; ?>>1: Cấp mới</option>
                                                    <option value="2" <?php echo (isset($cbof_action_type) && $cbof_action_type == '2') ? 'selected' : ''; ?>>2: Gia hạn</option>
                                                </select>
                                            </td>
                                            <td></td>
                                            <td></td>
                                            <td></td>
                                            <td></td>
                                        </tr> 
                                    
                                        <?php 
                                            if (isset($data_view) && is_array($data_view) && !empty($data_view)):
                                                $i = ($txt_current_page - 1) * $txt_row_per_page + 1; 
                                                foreach($data_view as $data):
                                                    $d_old = ($data['dold_expiry'] != '') ? date('d/m/Y', strtotime($data['dold_expiry'])) : '-';
                                                    $d_new = ($data['dnew_expiry'] != '') ? date('d/m/Y', strtotime($data['dnew_expiry'])) : '-';
                                                    $d_create = ($data['ddate_created'] != '') ? date('d/m/Y H:i', strtotime($data['ddate_created'])) : '-';
                                        ?>
                                          <tr class="even pointer">
                                             <td class="text-center"><?php echo $i; ?></td>
                                             <td><code style="color: #26b99a; font-size: 13px; font-weight: bold;"><?php echo $data['cmt5_account']; ?></code></td>
                                             <td class="text-left"><strong><?php echo Fview_text($data['cfullname']); ?></strong></td>   
                                             <td class="text-center"><small class="text-muted"><?php echo $data['clicense_key']; ?></small></td>
                                             <td class="text-center">
                                                 <?php if($data['naction_type'] == 1): ?>
                                                     <span class="label label-primary" style="font-size: 11px;">Cấp mới lần đầu</span>
                                                 <?php else: ?>
                                                     <span class="label label-warning" style="font-size: 11px;">Gia hạn License</span>
                                                 <?php endif; ?>
                                             </td>
                                             <td class="text-center text-muted" style="font-style: italic;"><?php echo $d_old; ?></td>
                                             <td class="text-center" style="font-weight: bold; color: #1abb9c;"><?php echo $d_new; ?></td>
                                             <td class="text-left"><small class="text-dark"><?php echo Fview_text($data['cnote']); ?></small></td>
                                             <td class="text-center" style="font-size: 12px; color: #666;"><?php echo $d_create; ?></td>
                                          </tr>
                                        <?php 
                                                $i++; 
                                                endforeach;
                                            else: 
                                        ?>
                                          <tr>
                                             <td colspan="9" class="text-center" style="font-style: italic; color: #73879C; padding: 20px;">
                                                <i class="fa fa-info-circle"></i> Chưa ghi nhận nhật ký lịch sử cấp phát License nào.
                                             </td>
                                          </tr>
                                        <?php endif; ?>
                                    </tbody>
                                </table>
                            </div>
                            
                            <table class="table qcare-table-pagination" cellspacing="1">
                                <tr>						
                                    <td></td>
                                    <td class="qcare-pagination-block">
                                        <div class="form-inline pull-right">	
                                            <label class="qcare-row-per-page-label"><?php echo $lbl_rows_per_page; ?>:</label>&nbsp;
                                            <input class="form-control text-center input-sm qcare-page-input" name="txt_row_per_page" type="text" size="5" value="<?php echo $txt_row_per_page; ?>" />&nbsp;
                                            <input name="btn_row_per_page" type="button" value="<?php echo $btn_choose; ?>" onclick="js_SetSubmitButtonClick(this.form, this.name);" class="btn btn-default btn-sm" />
                                        </div>
                                    </td>
                                    <td class="qcare-pagination-block">
                                        <div class="form-inline pull-right">		
                                            <?php if($txt_current_page > 1): ?>
                                            <input class="btn btn-default btn-sm" name="btn_previous" type="button" value="<<" onclick="js_SetSubmitButtonClick(this.form, 'btn_previous');"/>&nbsp;	
                                            <?php endif; ?>
                                            
                                            <label class="qcare-page-indicator"><?php echo $txt_current_page . ' / ' . $txt_total_page; ?></label>&nbsp;
                                            
                                            <?php if($txt_current_page < $txt_total_page): ?>
                                            <input class="btn btn-default btn-sm" name="btn_next" type="button" value=">>" onclick="js_SetSubmitButtonClick(this.form, 'btn_next');"/>&nbsp;
                                            <?php endif ?>
                                                    
                                            <input class="form-control text-center input-sm qcare-page-input page-num" name="txt_current_page" type="text" value="<?php echo $txt_current_page; ?>" size="5" />&nbsp;
                                                   
                                            <input name="btn_page_number" type="button" value="<?php echo $btn_choose; ?>" onclick="js_SetSubmitButtonClick(this.form, this.name);" class="btn btn-default btn-sm" />
                                        </div>	
                                    </td>
                                </tr>					
                            </table>
                            
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <input type="hidden" name="hidden_button" id="hidden_button"/>
    <input name="hidden_nid" type="hidden" value="0" />
    <input name="hidden_event" type="hidden" value="<?php echo $event; ?>" />
</form>