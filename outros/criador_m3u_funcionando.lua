-- Define start-time e stop-time de vídeos no VLC e adiciona ao M3U
local start_time = nil
local stop_time = nil
local m3u_file_path = "C:\\Users\\Ronie\\OneDrive\\Desktop\\Trechos.m3u"  -- Defina o caminho do arquivo M3U diretamente aqui
local input_wgt = nil
local label_start = nil
local label_stop = nil

function descriptor()
    return {
        title = "Criador M3U",
        version = "1.0",
        author = "Ronie",
        capabilities = {"input-listener"}
    }
end

function activate()
    vlc.msg.info("Script ativado!")
	vlc.msg.info("Caminho " .. m3u_file_path)
    local dlg = vlc.dialog("Definir Tempos")
	dlg:add_button("Add Start", set_start_time, 1)
    dlg:add_button("Stop and Set", set_stop_time, 2)    
	dlg:add_button("Add Full", add_full, 3)    
	dlg:add_label("Descrição:", 4)
	input_wgt = dlg:add_text_input("", 5)		
	label_start = dlg:add_label("00:00:00", 6)
	label_stop = dlg:add_label("00:00:00", 7)	
end

function deactivate()
    vlc.msg.info("Script desativado!")
end

function atualizar_labels()
	if start_time ~= nil then
		label_start:set_text(format_time(start_time))
	else
		label_start:set_text("--")
	end
	if stop_time ~= nil then
		label_stop:set_text(format_time(stop_time))
	else
		label_stop:set_text("--")
	end
end

function set_start_time()
    if vlc.object.input() then
        start_time = math.floor(vlc.var.get(vlc.object.input(), "time") / 1000000)
        vlc.msg.info("Start-Time definido para: " .. start_time .. " segundos.")
		atualizar_labels()
    else
        vlc.msg.warn("Nenhum vídeo está sendo reproduzido!")
    end
end

function set_stop_time()
	if start_time == nil then
        start_time = 0
	end
    if vlc.object.input() then
        stop_time = math.floor(vlc.var.get(vlc.object.input(), "time") / 1000000)
        vlc.msg.info("Stop-Time definido para: " .. stop_time .. " segundos.")
		append_to_m3u()
		atualizar_labels()
		start_time = nil
		stop_time = nil
    else
        vlc.msg.warn("Nenhum vídeo está sendo reproduzido!")
    end
end

function format_time(seconds)
    -- Calcular horas, minutos e segundos
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local sec = seconds % 60
    
    -- Formatar no formato HH:MM:SS
    return string.format("%02d:%02d:%02d", hours, minutes, sec)
end


function append_to_m3u()
    if not start_time or not stop_time then
        vlc.msg.warn("Defina os tempos primeiro!")
        return
    end

    if not m3u_file_path or m3u_file_path == "" then
        vlc.msg.warn("O caminho do arquivo M3U não foi definido!")
        return
    end

    local input_item = vlc.input.item()
    if not input_item then
        vlc.msg.warn("Nenhum vídeo está sendo reproduzido!")
        return
    end

    local uri = input_item:uri()
    local file_path = vlc.strings.decode_uri(uri)
	local m3u_desc = input_wgt:get_text()

    local m3u_entry = "\n#" .. input_item:name() .. ": " .. format_time(start_time) .. " até " .. format_time(stop_time) .. " -- " .. m3u_desc
    m3u_entry = m3u_entry .. "\n"	
	m3u_entry = m3u_entry .. "#EXTINF:-1," .. input_item:name() .. "\n"
    m3u_entry = m3u_entry .. "#EXTVLCOPT:start-time=" .. start_time .. "\n"
    m3u_entry = m3u_entry .. "#EXTVLCOPT:stop-time=" .. stop_time .. "\n"
    m3u_entry = m3u_entry .. file_path .. "\n"

    local file = io.open(m3u_file_path, "a") -- Modo de acréscimo (append)
    if file then
        file:write(m3u_entry)
        file:close()
        vlc.msg.info("Entrada adicionada ao arquivo M3U: " .. m3u_file_path)
    else
        vlc.msg.err("Não foi possível abrir o arquivo M3U para escrita!")
    end
end

function add_full()
	start_time = nil
	stop_time = nil
	atualizar_labels()

    local input_item = vlc.input.item()
    local uri = input_item:uri()
    local file_path = vlc.strings.decode_uri(uri)
	local m3u_desc = input_wgt:get_text()

    local m3u_entry = "\n#" .. input_item:name() .. " -- " .. m3u_desc
    m3u_entry = m3u_entry .. "\n"	
	m3u_entry = m3u_entry .. "#EXTINF:-1," .. input_item:name() .. "\n"
    m3u_entry = m3u_entry .. file_path .. "\n"

    local file = io.open(m3u_file_path, "a") -- Modo de acréscimo (append)
    if file then
        file:write(m3u_entry)
        file:close()
        vlc.msg.info("Entrada adicionada ao arquivo M3U: " .. m3u_file_path)
    else
        vlc.msg.err("Não foi possível abrir o arquivo M3U para escrita!")
    end
end


