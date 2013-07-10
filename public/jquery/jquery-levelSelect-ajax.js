/*
 通用数据水平层级选择控件
 作者：绿豆糕
 版本：v0.70
 修改时间：2010年11月22日
 要求数据格式：纯文本，数据项之间以","分隔，数据项数值和描述文本之间以":"分隔，可以在参数中自定义分隔符。
 */
;(function($){
//弹出层
    $.openLayer = function(p){
        var param = $.extend({
            maxItems : 5,					//最多选取项数字限制
            showLevel : 5,					//显示级别
            oneLevel : true,				//是否限制选择相同级别的数据，可以不为同一个父节点，
            //false为不限制，可以同时选择不同级别的数据，true为限制。
            onePLevel : false,				//是否限制选择相同级别,并且是同一个父节点的数据，
            //false为不限制，可以同时选择不同级别的数据，true为限制。
            //此参数只有在oneLevel:true时才有效
            splitChar : ",:",				//数据分隔符，第一个字符为各项之间的分隔符，第二个为每项中id和显示字符串的分隔符。
            returnValue : "",				//以，分隔的选取结果id存放的位置id，默认为一个input。
            returnText : "",				//以，分隔的选取结果文字存放的位置id，可以为span，div等容器。
            title : "选择城市",				//弹出窗口标题
            width : 650,					//弹出窗口宽度
            span_width : {d1:70,d3:150},	//可以自定义每一层级数据项显示宽度，用来对其排版。
            url : "",						//ajax请求url
            pid : "0",						//父id
            shared : true,					//如果页面中有多于1个的弹出选择,是否共享缓存数据
            index : 1,						//如果页面中有多于1个的弹出选择,如果不共享之前的操作界面则必须设置不同的index值，否则不同的弹出选择共享相同的操作界面。
            cacheEnable : true,				//是否允许缓存
            dragEnable : true,				//是否允许鼠标拖动
            pText : ""
        },p||{});

        var fs = {
            init_Container : function(){	//初始化头部和内容容器
                //标题
                var TITLE = param.title + ",最多能选择 " + param.maxItems + " 项！";
                var CLOSE = "<span id='_cancel' style='cursor:pointer;'>[取消]</span>&nbsp;&nbsp;<span id='_ok' style='cursor:pointer;'>[确定]</span>";
                //头部
                var htmlDiv = "<div id='heads'><div id='headdiv'><span id='title'>" + TITLE + "</span><span id='close'>" + CLOSE + "</span></div>";
                //内容容器创建部分
                htmlDiv += "<div id='container_city'></div></div>";
                return htmlDiv;
            },
            init_area : function(){			//初始化数据容器
                var _container = $("#container_city");
                //已选择项容器
                var selArea = $("<div id='selArea'><div>已选择项目：</div></div>");
                _container.append(selArea);
                if (param.maxItems == 1){ selArea.hide(); }

                //初始化第一层级数据容器，以后各级容器都clone本容器
                var d1 = $("<div id='d1'></div>");
                var dc = $("<div id='dc'></div>");

                _container.append(dc).append(d1);//加入数据容器中
                dc.hide();
                fs.add_data(d1);//添加数据
            },
            add_data : function(targetid){					//添加数据到容器，添加事件，初始化下一层次容器
                targetid.nextAll().remove();				//删除目标容器之后的所有同级别容器

                var pid = param.pid;						//查询数据的参数，父id
                var url = param.url;						//ajax查询url
                var data = "";								//返回数据变量

                if(param.cacheEnable){ data = _cache[pid];}	//如果cache开启则首先从cache中取得数据

                //如果cache中没有数据并且url和pid都设置了,发起ajax请求
                if ((data == null || data == "") &&  url != ""){
                    $.ajax({
                        type : "post",						//post方式
                        url : url,							//ajax查询url
                        data : {pid:pid},					//参数
                        async : false,						//同步方式，便于拿到返回数据做统一处理
                        beforeSend : function (){ },		//ajax查询请求之前动作，比如提示信息……
                        success : function (d) {			//ajax请求成功后返回数据
                            data = d;
                            if(param.cacheEnable){ _cache[pid] = data;}		//cache允许,保存数据到cache
                        }
                    });
                }

                //cache和ajax都没有数据或者错误,添加提示信息返回
                if(data == "" || data == null){
                    targetid.empty().show().append($("<span style='color:red;'>没有下级数据！</span>"));
                    return;
                }

                var span_width = eval("param.span_width."+targetid.attr("id"));			//每个数据显示项的宽度
                span_width = (span_width == undefined ? param.span_width.d1:span_width );//没有设置的话，就使用第一个数据容器的值
                var inspan_width = ($.browser.msie)?1:3;								//内部文字和checkbox之间的距离

                var dat = data.split(param.splitChar.charAt(0));						//根据设定分隔符对数据做第一次分隔，获得数据项数组
                var html = [];															//格式化数据存放容器，为了提高效率，使用了数组
                var ss = [];
                //循环获得格式化的显示字符串
                for(var i = 0 ; i < dat.length ; i++){
                    ss = dat[i].split(param.splitChar.charAt(1));		//第二次分隔，获得每个数据项中的数据值和显示字符串
                    html.push("<span title='"+dat[i]+"' name='"+pid+"' style='width:"+span_width+"px;white-space:nowrap;float:left;'>");
                    html.push("<input type='checkbox' value='" + ss[0] + "'>");
                    html.push("<span name='"+targetid.attr("id")+"' style='margin-left:"+inspan_width+"px;cursor:pointer;'>" + ss[1] + "</span>");
                    html.push("</span>");
                }
                targetid.empty().show().append($(html.join("")));		//格式化的html代码放入目标容器
                if(param.maxItems > 1){fs.change_status(targetid);}		//同步状态,单选状态无必要

                fs.add_input_event(targetid);							//加入input的事件绑定
                fs.add_span_event(targetid);							//加入span的事件绑定
            },
            init_event : function(){		//绑定已选择框中checkbox的事件，确定，取消事件响应
                $("#selArea").find(":input").live("click",function(){
                    $(this).parent().remove();
                    $("#container_city > div").find(":input[value="+this.value+"]").attr("checked",false);
                });
                $("#_cancel").click(function(){
                    $("#bodybg").hide();
                    $("#popupAddr").fadeOut();
                });
                $("#_ok").click(function(){
                    var vals = "";
                    var txts = "";
                    $("#selArea").find(":input").each(function(i){
                        vals += ("," + this.value);
                        txts += ("," + $(this).next().text());
                    });
                    fs.set_returnVals(param.returnValue,vals);
                    fs.set_returnVals(param.returnText,txts);

                    $("#bodybg").hide();
                    $("#popupAddr").fadeOut();
                });
            },
            change_status : function(targetid){ //切换不同元素，形成不同下级列表时候，同步已选择区的元素和新形成区元素的选中状态
                var selArea = $("#selArea");
                var selinputs = selArea.find(":input");
                var vals =[];

                if(selinputs.length > 0){
                    selinputs.each(function(){ vals.push(this.value); });
                }
                targetid.find(":input").each(function(){
                    if($.inArray(this.value,vals) != -1){ this.checked = true; }
                });
            },
            add_input_event : function(targetid){	//新生成的元素集合添加input的单击事件响应
                var selArea = $("#selArea");
                targetid.find(":input").click(function(){
                    if (param.maxItems == 1){
                        selArea.find("span").remove();
                        $("#container_city > div").find(":checked:first").not($(this)).attr("checked",false);
                        $(this).css("color","white");
                        selArea.append($(this).parent().clone());
                        $("#_ok").click();
                    }else {
                        if(this.checked && fs.check_level(this) && fs.check_num(this)){
                            selArea.append($(this).parent().clone().css({"width":"","background":"","border":""}));
                        }else{
                            selArea.find(":input[value="+this.value+"]").parent().remove();
                        }
                    }
                });
            },
            add_span_event : function(targetid){	//新生成的元素集合添加span的单击事件响应
                var maxlev = param.showLevel;
                var thislevel = parseInt(targetid.attr("id").substring(1));

                var spans = targetid.children("span");
                spans.children("span").click(function(e){
                    if (maxlev > thislevel){
                        var next=$("#dc").clone();
                        next.attr("id","d"+(thislevel+1));
                        targetid.after(next);

                        spans.css({"background":"","margin":""});
                        $(this).parent().css({"background":"orange","margin":"-1"});
                        param.pid = $(this).prev().val();
                        fs.add_data(next,param);
                    }else{
                        alert("当前设置只允许显示" +  maxlev + "层数据！");
                    }
                });
            },
            check_num : function(obj){	//检测最多可选择数量
                if($("#selArea").find(":input").size() < param.maxItems){
                    return true;
                }else{
                    obj.checked = false;
                    alert("最多只能选择"+param.maxItems+"个选项");
                    return false;
                }
            },
            check_level : function(obj){	//检测是否允许选取同级别选项或者同父id选项
                var selobj = $("#selArea > span");
                if(selobj.length ==0) return true;

                var oneLevel = param.oneLevel;
                if(oneLevel == false){
                    return true;
                }else{
                    var selLevel = selobj.find("span:first").attr("name");		//已选择元素的级别
                    var thislevel = $(obj).next().attr("name");					//当前元素级别
                    if(selLevel != thislevel) {
                        obj.checked = false;
                        alert("当前设定只允许选择同一级别的元素！");
                        return  false;
                    }else{
                        var onePLevel = param.onePLevel;		//是否设定只允许选择同一父id的同级元素
                        if (onePLevel == false) {
                            return true;
                        }else{
                            var parentId = selobj.attr("name");					//已选择元素的父id
                            var thisParentId = $(obj).parent().attr("name");	//当前元素父id
                            if (parentId != thisParentId){
                                obj.checked = false;
                                alert("当前设定只允许选择同一级别并且相同上级的元素！");
                                return false;
                            }
                            return true;
                        }
                    }
                }
            },
            set_returnVals : function(id,vals) {	//按"确定"按钮时处理、设置返回值
                if(id != ""){
                    var Container = $("#" + id);
                    if(Container.length > 0){
                        if(Container.is("input")){
                            Container.val(vals.substring(1));
                        }else{
                            Container.text(vals.substring(1));
                        }
                    }
                }
            },
            init_style : function() {	//初始化css
                var _margin = 4;
                var _width = param.width-_margin*5;

                var css = [];
                var aotu = "border:2px groove";
                css.push("#popupAddr {position:absolute;border:3px ridge;width:"+param.width+"px;height:auto;background-color:#e3e3e3;z-index:99;-moz-box-shadow:5px 5px 5px rgba(0,0,0,0.5);box-shadow:5px 5px 5px rgba(0,0,0,0.5);filter:progid:DXImageTransform.Microsoft.dropshadow(OffX=5,OffY=5,Color=gray);-ms-filter:progid:DXImageTransform.Microsoft.dropshadow(OffX=5,OffY=5,Color='gray');}");
                css.push("#bodybg {width:100%;z-index:98;position:absolute;top:0;left:0;background-color:#fff;opacity:0.1;filter:alpha(opacity =10);}");
                css.push("#heads {width:100%;font-size:12px;margin:0 auto;}");
                css.push("#headdiv {color:white;background-color:green;font-size:13px;height:25px;margin:1px;" +aotu+"}");
                css.push("#title {line-height:30px;padding-left:20px;float:left;}");
                css.push("#close {float:right;padding-right:12px;line-height:30px;}");
                css.push("#container_city {width:100%;height:auto;}");
                css.push("#selArea {width:"+_width+"px;height:48px;margin:"+_margin+"px;padding:5px;background-color:#f4f4f4;float:left;"+aotu+"}");
                css.push("#pbar {width:"+_width+"px;height:12px;margin:4px;-moz-box-sizing: border-box;display:block;overflow: hidden;font-size:1px;border:1px solid red;background:#333333;float:left;}");

                var d_css = "{width:"+_width+"px;margin:"+_margin+"px;padding:5px;height:auto;background-color:khaki;float:left;"+aotu+"}";
                css.push("dc "+d_css);
                for (i = 1; i <=param.showLevel; i++) { css.push("#d" + i + " " + d_css); }
                $("head").append($("<style>"+css.join(" ")+"</style>"));
            }
        };

        if (window._cache == undefined || !param.shared ){ _cache = {}; }
        if (window._index == undefined) { _index = param.index; }

        fs.init_style();//初始化样式

        var popupDiv = $("#popupAddr");	//创建一个div元素
        if (popupDiv.length == 0 ) {
            popupDiv = $("<div id='popupAddr'></div>");
            $("body").append(popupDiv);
        }
        var yPos = ($(window).height()-popupDiv.height()) / 2;
        var xPos = ($(window).width()-popupDiv.width()) / 2;
        popupDiv.css({"top": yPos,"left": xPos}).show();

        var bodyBack = $("#bodybg");  //创建背景层
        if (bodyBack.length == 0 ) {
            bodyBack = $("<div id='bodybg'></div>");
            bodyBack.height($(window).height());
            $("body").append(bodyBack);
            popupDiv.html(fs.init_Container());	//弹出层内容
            fs.init_area();
            fs.init_event();
        }else {
            if (_index != param.index) {
                popupDiv.html(fs.init_Container(param));
                fs.init_area();
                fs.init_event();
                _index = param.index;
            }
        }

        if (param.dragEnable) {		//允许鼠标拖动
            var _move=false;		//移动标记
            var _x,_y;				//鼠标离控件左上角的相对位置
            popupDiv.mousedown(function(e){
                _move=true;
                _x=e.pageX-parseInt(popupDiv.css("left"));
                _y=e.pageY-parseInt(popupDiv.css("top"));
            }).mousemove(function(e){
                    if(_move){
                        var x=e.pageX-_x;//移动时根据鼠标位置计算控件左上角的绝对位置
                        var y=e.pageY-_y;
                        popupDiv.css({top:y,left:x});//控件新位置
                    }}).mouseup(function(){ _move=false; });
        }
        bodyBack.show();
        popupDiv.fadeIn();
    }

})(jQuery)

_cache ={"0":"2:安徽省,3:北京,4:甘肃省,5:河北省,6:黑龙江省,7:河南省,8:内蒙古,9:吉林省,10:辽宁省,11:宁夏省,12:青海省,13:山东省,14:山西省,15:天津,16:新疆,19:重庆,20:福建省,21:广东省,22:广西省,23:贵州省,24:海南省,25:湖北省,26:湖南省,27:江西省,28:四川省,29:西藏,30:云南省,32:上海,33:江苏省,34:浙江省,251:陕西省"
    ,"2":"1145:合肥市,1154:芜湖市,1163:蚌埠市,1172:淮南市,1180:马鞍山市,1187:淮北市,1193:铜陵市,1199:安庆市,1212:黄山市,1221:滁州市,1231:阜阳市,1245:宿州市,1252:六安市,1259:宣城市,1267:巢湖市,1273:池州市,3470:亳州市"
    ,"3":"35:东城区,36:西城区,37:崇文区,38:宣武区,39:朝阳区,40:丰台区,41:石景山区,42:海淀区,43:门头沟区,44:房山区,45:通州区,46:顺义区,48:昌平区,49:大兴区,50:平谷区,51:怀柔区,52:密云县,53:延庆县,3468:经济技术开发区"
    ,"4":"3164:兰州市,3174:嘉峪关市,3176:金昌市,3180:白银市,3187:天水市,3196:酒泉市,3204:张掖市,3211:武威市,3216:定西市,3224:陇南市,3234:平凉市,3242:庆阳市,3251:临夏回族自治州,3260:甘南藏族自治州"
    ,"5":"74:石家庄市,99:唐山市,116:秦皇岛市,125:邯郸市,146:邢台市,167:保定市,194:张家口市,213:承德市,226:沧州市,244:廊坊市,255:衡水市"
    ,"6":"726:哈尔滨市,747:齐齐哈尔市,765:鸡西市,776:鹤岗市,786:双鸭山市,796:大庆市,807:伊春市,826:佳木斯市,839:七台河市,845:牡丹江市,857:黑河市,865:绥化市,876:大兴安岭地区"
    ,"7":"1667:郑州市,1681:开封市,1693:洛阳市,1710:平顶山市,1722:安阳市,1733:鹤壁市,1740:新乡市,1754:焦作市,1764:济源市,1767:濮阳市,1775:许昌市,1783:漯河市,1789:三门峡市,1797:南阳市,1812:商丘市,1823:信阳市,1835:周口市,1846:驻马店市"
    ,"8":"404:呼和浩特市,415:包头市,426:乌海市,431:赤峰市,445:呼伦贝尔市,459:兴安盟,467:通辽市,475:锡林郭勒盟,488:乌兰察布市,509:巴彦淖尔市,517:阿拉善盟,3471:鄂尔多斯市"
    ,"9":"649:长春市,661:吉林市,672:四平市,680:辽源市,686:通化市,695:白山市,703:松原市,710:白城市,717:延边朝鲜族自治州"
    ,"10":"521:沈阳市,536:大连市,548:鞍山市,557:抚顺市,566:本溪市,574:丹东市,582:锦州市,591:营口市,599:阜新市,608:辽阳市,617:盘锦市,623:铁岭市,632:朝阳市,641:葫芦岛市"
    ,"11":"3321:银川市,3328:石嘴山市,3336:吴忠市,3339:中卫市,3345:固原市"
    ,"12":"3269:西宁市,3276:海东地区,3285:海北藏族自治州,3290:黄南藏族自治州,3295:海南藏族自治州,3301:果洛藏族自治州,3308:玉树藏族自治州,3315:海西蒙古族藏族自治州"
    ,"13":"1496:济南市,1508:青岛市,1522:淄博市,1532:枣庄市,1540:东营市,1547:烟台市,1561:潍坊市,1575:济宁市,1589:泰安市,1597:威海市,1603:日照市,1608:莱芜市,1612:临沂市,1626:德州市,1639:聊城市,1649:滨州市,1657:菏泽市"
    ,"14":"268:太原市,280:大同市,293:阳泉市,300:长治市,315:晋城市,323:朔州市,331:忻州市,346:吕梁市,360:晋中市,372:临汾市,390:运城市"
    ,"15":"55:和平区,56:河东区,57:河西区,58:南开区,59:河北区,60:红桥区,61:滨海新区(原塘沽区),62:滨海新区(原汉沽区),63:滨海新区(原大港区),64:东丽区,65:西青区,66:津南区,67:北辰区,69:宁河县,70:武清区,71:静海县,72:宝坻区,73:蓟县,3467:经济技术开发区"
    ,"16":"3352:乌鲁木齐市,3362:克拉玛依市,3368:吐鲁番地区,3372:哈密地区,3376:昌吉回族自治州,3385:博尔塔拉蒙古自治州,3389:巴音郭楞蒙古自治州,3399:阿克苏地区,3409:克孜勒苏柯尔克孜自治州,3414:喀什地区,3427:和田地区,3436:伊犁哈萨克自治州,3448:塔城地区,3456:阿勒泰地区,3465:石河子市,3741:阿拉尔市,3743:图木舒克市,3745:五家渠市"
    ,"19":"2453:万州区,2454:涪陵区,2455:渝中区,2456:大渡口区,2457:江北区,2458:沙坪坝区,2459:九龙坡区,2460:南岸区,2461:北碚区,2462:綦江区（原万盛区）,2463:大足区（原双桥区）,2464:渝北区,2465:巴南区,2467:长寿区,2468:綦江区（原綦江县）,2469:潼南县,2470:铜梁县,2471:大足区（原大足县）,2472:荣昌县,2473:璧山县,2474:梁平县,2475:城口县,2476:丰都县,2477:垫江县,2478:武隆县,2479:忠县,2480:开县,2481:云阳县,2482:奉节县,2483:巫山县,2484:巫溪县,2485:黔江区,2486:石柱土家族自治县,2487:秀山土家族苗族自治县,2488:酉阳土家族苗族自治县,2489:彭水苗族土家族自治县,2491:江津区,2492:合川区,2493:永川区,2494:南川区,3909:高新区,10062:北部新区"
    ,"20":"1278:福州市,1293:厦门市,1302:莆田市,1308:三明市,1322:泉州市,1335:漳州市,1348:南平市,1360:龙岩市,1369:宁德市"
    ,"21":"2130:广州市,2144:韶关市,2157:深圳市,2165:珠海市,2169:汕头市,2179:佛山市,2187:江门市,2196:湛江市,2207:茂名市,2214:肇庆市,2224:惠州市,2231:梅州市,2241:汕尾市,2247:河源市,2255:阳江市,2261:清远市,2271:东莞市,2272:中山市,2273:潮州市,2278:揭阳市,2285:云浮市"
    ,"22":"2292:南宁市,2302:柳州市,2311:桂林市,2330:梧州市,2339:北海市,2345:防城港市,2351:钦州市,2357:贵港市,2363:玉林市,2379:崇左市,2389:来宾市,2395:贺州市,2400:百色市,2413:河池市"
    ,"23":"2709:贵阳市,2720:六盘水市,2725:遵义市,2740:铜仁地区,2751:黔西南布依族苗族自治州,2760:毕节地区,2769:安顺市,2776:黔东南苗族侗族自治州,2793:黔南布依族苗族自治州"
    ,"24":"2425:海口市,2430:三亚市,2432:五指山市,2433:琼海市,2434:儋州市,2436:文昌市,2437:万宁市,2438:东方市,2439:定安县,2440:屯昌县,2441:澄迈县,2442:临高县,2443:白沙黎族自治县,2444:昌江黎族自治县,2445:乐东黎族自治县,2446:陵水黎族自治县,2447:保亭黎族苗族自治县,2448:琼中黎族苗族自治县,3469:经济技术开发区,3884:西南中沙群岛办事处"
    ,"25":"1857:武汉市,1872:黄石市,1880:十堰市,1890:宜昌市,1905:襄阳市(原襄樊市),1916:鄂州市,1921:荆门市,1927:孝感市,1937:荆州市,1947:黄冈市,1959:咸宁市,1967:恩施土家族苗族自治州,1977:随州市,1978:仙桃市,1979:潜江市,1980:天门市,1981:神农架林区"
    ,"26":"1982:长沙市,1993:株洲市,2004:湘潭市,2011:衡阳市,2025:邵阳市,2039:岳阳市,2050:常德市,2061:张家界市,2067:益阳市,2075:郴州市,2088:永州市,2101:怀化市,2115:娄底市,2121:湘西土家族苗族自治州"
    ,"27":"1379:南昌市,1390:景德镇市,1396:萍乡市,1403:九江市,1417:新余市,1421:鹰潭市,1426:赣州市,1446:宜春市,1457:上饶市,1470:吉安市,1484:抚州市"
    ,"28":"2495:成都市,2516:自贡市,2524:攀枝花市,2531:泸州市,2540:德阳市,2548:绵阳市,2559:广元市,2568:遂宁市,2574:内江市,2581:乐山市,2594:南充市,2605:宜宾市,2617:广安市,2624:达州市,2632:雅安市,2641:阿坝藏族羌族自治州,2655:甘孜藏族自治州,2674:凉山彝族自治州,2692:巴中市,2697:眉山市,2704:资阳市"
    ,"29":"2954:拉萨市,2964:昌都地区,2980:山南地区,2993:日喀则地区,3012:那曲地区,3023:阿里地区,3032:林芝地区"
    ,"30":"2806:昆明市,2822:曲靖市,2833:玉溪市,2844:昭通市,2856:楚雄彝族自治州,2867:红河哈尼族彝族自治州,2881:文山壮族苗族自治州,2901:西双版纳傣族自治州,2905:大理白族自治州,2919:保山市,2924:德宏傣族景颇族自治州,2931:丽江市,2936:怒江傈僳族自治州,2941:迪庆藏族自治州,2945:临沧市,3472:普洱市"
    ,"32":"881:黄浦区,883:卢湾区(现属黄浦区),884:徐汇区,885:长宁区,886:静安区,887:普陀区,888:闸北区,889:虹口区,890:杨浦区,891:闵行区,892:宝山区,893:嘉定区,894:浦东新区,895:金山区,896:松江区,898:南汇区（属浦东新区）,899:奉贤区,900:青浦区,901:崇明县"
    ,"33":"902:南京市,919:无锡市,929:徐州市,942:常州市,951:苏州市,963:南通市,973:连云港市,983:淮安市,993:盐城市,1004:扬州市,1013:镇江市,1021:泰州市,1029:宿迁市"
    ,"34":"1036:杭州市,1051:宁波市,1064:温州市,1077:嘉兴市,1086:湖州市,1091:绍兴市,1099:金华市,1110:衢州市,1118:舟山市,1124:台州市,1135:丽水市"
    ,"251":"3040:西安市,3055:铜川市,3061:宝鸡市,3075:咸阳市,3091:渭南市,3104:延安市,3119:汉中市,3132:安康市,3143:商洛市,3151:榆林市"};						//缓存