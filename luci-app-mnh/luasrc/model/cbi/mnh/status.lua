local dsp = require "luci.dispatcher"
local tpl = require "luci.template"

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
	for i, n in pairs({"type", "port", "server", "service"}) do
		str = str .. n .. ": " .. self.map:get(section, n) .. "<br />"
	end
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
								case "connecting":
								default:
									e.innerHTML = `${st[i].status}`;
									break;
								case "fail":
									e.innerHTML = `${st[i].status}<br />${st[i].error}`;
									break;
								case "success":
								case "disconnected":
									e.innerHTML = `${st[i].status}<br />${st[i].addr}`;
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
