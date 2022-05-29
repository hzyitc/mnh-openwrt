local dsp = require "luci.dispatcher"
local tpl = require "luci.template"

local kvmsg = '%s: <font color="blue">%s</font><br />'

local m = Map("mnh", translate("mnh"))

local s = m:section(TypedSection, "instance", translate("Instance"))
s.template = "cbi/tblsection"
s.anonymous = true
-- s.addremove = true
-- s.extedit = dsp.build_url("admin", "services", "mnh", "instance", "%s")

local o = s:option(DummyValue, "id", translate("ID"))
function o.cfgvalue(self, s)
	return self.map:get(s, "id")
end

local o = s:option(DummyValue, "status", translate("Status"))
o.rawhtml = true

local o = s:option(Button, "button_disabled", translate("Enable/Disable"))
function o.render(self, section, scope)
	local v = self.map:get(section, "disabled")
	if v == nil or v == 0 then
		self.title = translate("Enabled")
		self.inputstyle = "save"
	else
		self.title = translate("Disabled")
		self.inputstyle = "reset"
	end
	Button.render(self, section, scope)
end
function o.write(self, section, value)
	local v = self.map:get(section, "disabled")
	if v == nil or v == 0 then
		self.map:set(section, "disabled", 1)
	else
		self.map:del(section, "disabled")
	end
end

local o = s:option(DummyValue, "config", translate("Config"))
o.rawhtml = true
function o.cfgvalue(self, section)
	local i, n
	local str = ""

	str = str .. kvmsg:format(translate("Type"), self.map:get(section, "type") or "")
	str = str .. kvmsg:format(translate("port"), self.map:get(section, "port") or "0")
	str = str .. kvmsg:format(translate("server"), self.map:get(section, "server") or "")
	str = str .. kvmsg:format(translate("service"), self.map:get(section, "service") or "")

	return str
end

local tpl_script = tpl.Template(nil, [[
	<script type="text/javascript">
		XHR.poll(-1, '<%=url('admin/services/mnh/status')%>', null,
			function(x, st) {
				if(st) {
					Object.keys(st).forEach(i => {
						var e = document.getElementById(`cbi-mnh-${i}-status`);
						if(e) {
							switch(st[i].status) {
								case "not running":
									e.innerHTML = `<font color="red"><%=translate("not running")%></font>`;
									break;
								case "connecting":
									e.innerHTML = `<font color="orange"><%=translate("connecting")%></font>`;
									break;
								case "fail":
									e.innerHTML = `<font color="red"><%=translate("fail")%></font>` + "<br />"
													`<font color="red">${st[i].error}</font>`;
									break;
								case "success":
									e.innerHTML = `<font color="green"><%=translate("success")%></font>` + "<br />" + 
													`<font color="blue">${st[i].addr}</font>`;
									break;
								case "disconnected":
									e.innerHTML = `<font color="orange"><%=translate("disconnected")%></font>` + "<br />" + 
													`<font color="blue">${st[i].addr}</font>`;
									break;
								default:
									e.innerHTML = `<font color="orange">${st[i].status}</font>`;
									break;
							}
						}
					});
				}
			}
		);
	</script>
]])

local s = m:section(SimpleSection)
function s.render(self, scope)
	tpl_script:render()
end

return m
