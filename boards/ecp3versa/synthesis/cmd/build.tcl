prj_project open "kvs_hdl.ldf"
prj_run Synthesis -impl kvs_hdl1
prj_run Translate -impl kvs_hdl1
prj_run Map -impl kvs_hdl1
prj_run PAR -impl kvs_hdl1
prj_run PAR -impl kvs_hdl1 -task PARTrace
prj_run Export -impl kvs_hdl1 -task Bitgen
prj_project close
