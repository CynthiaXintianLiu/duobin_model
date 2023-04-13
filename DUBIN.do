xtset code year
xtdes
describe//data describe 
//空间截面设置
spset
**step 1 LM检验
spatwmat using "D:\桌面\M1.dta",name(w) standardize
spmat dta w var1-var24 norm(row) replace
drop var1-var24
set matsize 144
mat TMAT=I(6)
mat Wxt=TMAT#w
svmat Wxt
save Wxt.dta,replace
spatwmat using Wxt.dta, name(ww) standardize
use "D:\桌面\毕业论文数据\stata空间计量\PANEL.dta" 
reg Year SFM RL Urb IE In IS
spatdiag, w(ww)
//step 2 multi-linearity
xtreg year sfm rl urb ie pgdp is rlxurb rlxie rlxis,fe vce(cluster code)
asdoc estat vif
reg rl urb ie pgdp is rlxurb,vce(cluster code)
reg rl urb ie pgdp is rlxurb rlxie rlxis,vce(cluster code)
** step 3 HAUSMAN test
spatwmat using "D:\桌面\M1.dta",name(w) standardize
xsmle year sfm rl urb ie pgdp is rlxurb, model(sdm) wmat(w) hausman nolog


xtreg sfm rl urb ie pgdp is rlxurb, fe 
est store fe
xtreg sfm rl urb ie pgdp is rlxurb, re 
est store re
hausman fe re
outreg2 using myfile , word ctitle(FE) dec(3) adds(Hausman, `r(chi2)', p-value, `r(p) ') replace


**step 4： LR test sdm，sar，sem
spatwmat using "D:\桌面\M1.dta",name(w) standardize
xsmle sfm rl urb ie pgdp is rlxurb,fe model(sdm) wmat(w) type(both) nolog noeffects
est store sdm_a
xsmle sfm rl urb ie pgdp is rlxurb,fe model(sar) wmat(w) type(both) nolog noeffects
est store sar_a
xsmle sfm rl urb ie pgdp is rlxurb,fe model(sem) emat(w) type(both) nolog noeffects
est store sem_a
lrtest sdm_a sar_a,df(5)
lrtest sdm_a sem_a,df(5)
lrtest sem_a sar_a,df(10)
**Wald test：sdm，sar，sem
xsmle sfm rl urb ie pgdp is rlxurb, wmat(w) model(sdm) robust nolog effects fe r    
test [Wx]rl = [Wx]urb=[Wx]ie=[Wx]is=[Wx]pgdp=[Wx]rlxurb=[Wx]rlxie=[Wx]rlxis=0
testnl ([Wx]rl=-[Spatial]rho*[Main]rl ) ([Wx]urb=-[Spatial]rho*[Main]urb)([Wx]ie=-[Spatial]rho*[Main]ie) ([Wx]is =-[Spatial]rho*[Main]is)([Wx]rlxurb=-[Spatial]rho*[Main]rlxurb )([Wx]rlxie=-[Spatial]rho*[Main]rlxie)([Wx]rlxis=-[Spatial]rho*[Main]rlxis)

////
xsmle sfm rl urb ie pgdp is rlxurb, wmat(w) model(sdm) robust nolog effects fe r    
test [Wx]rl = [Wx]urb=[Wx]ie=[Wx]pgdp=[Wx]is=[Wx]rlxurb=0
testnl ([Wx]rl=-[Spatial]rho*[Main]rl ) ([Wx]urb=-[Spatial]rho*[Main]urb)([Wx]ie=-[Spatial]rho*[Main]ie) ([Wx]is=-[Spatial]rho*[Main]is )([Wx]rlxurb=-[Spatial]rho*[Main]rlxurb )

///step5：
**time fixed
xsmle sfm rl urb ie pgdp is rlxurb,fe model(sdm) wmat(w) type(time) nolongeffects posthessian
est store sdm_time
**individual fixed
xsmle sfm rl urb ie pgdp is rlxurb,fe model(sdm) wmat(w) type(ind) nolongeffects
est store sdm_ind
**
xsmle sfm rl urb ie pgdp is rlxurb,fe model(sdm) wmat(w) type(both) nolongeffects
est store sdm_both
lrtest sdm_both sdm_time,df(5)
lrtest sdm_both sdm_ind,df(23)

///step6：direct and indirect
***
asdoc xsmle sfm rl urb ie pgdp is rlxurb,fe model(sdm) wmat(w) type(ind) nolog effects fe r2 robust
asdoc xsmle SFM RL urb ie pgdp is isxpgdp pgdpxie urbxis,fe model(sar) wmat(w) type(time) nolog noeffects fe r2

***gongxianxing 
xsmle sfm rl urb ie pgdp rlxurb rlxie,fe r wmat(w) model(sdm) nolog noeffects
est sto sfm 
esttab sfm rl urb ie pgdp is rlxurb rlxie rlxis

*Moran's I
cd "D:\桌面\"
//全局莫兰
spatwmat using Wbin.dta,name(w)
//局部莫兰
spatwmat using Wbin.dta,name(w) standardize
use "‪D:\桌面\pro_data.dta"
spatgsa var1,weights(w) moran
spatlsa var2,weights(w) moran graph(moran) symbol(id) id(Name)

//Queen
cd "D:\桌面\"
//全局莫兰
spatwmat using M2.dta,name(w)
//局部莫兰
spatwmat using M2.dta,name(w) standardize
use "D:\桌面\pro_data.dta"
spatgsa var2015,weights(w) moran
spatlsa var2015,weights(w) moran graph(moran) symbol(id) id(Name)
