-- Define start-time e stop-time de vídeos no VLC e adiciona ao M3U
local start_time = nil
local stop_time = nil
local m3u_file_path = nil

function descriptor()
    return {
        title = "Set Times and Append to M3U",
        version = "1.1",
        author = "Seu Nome",
        capabilities = {"input-listener"}
    }
end

function activate()
    vlc.msg.info("Script ativado!")
    local dlg = vlc.dialog("Definir Tempos")
    dlg:add_button("Definir Start-Time", set_start_time, 1)
    dlg:add_button("Definir Stop-Time", set_stop_time, 2)
    dlg:add_button("Selecionar Arquivo M3U", select_m3u_file, 3)
    dlg:add_button("Adicionar ao M3U", append_to_m3u, 4)
end

function deactivate()
    vlc.msg.info("Script desativado!")
end

function set_start_time()
    start_time = vlc.var.get(vlc.object.input(), "time")
    vlc.msg.info("Start-Time definido para: " .. start_time .. " segundos.")
end

function set_stop_time()
    stop_time = vlc.var.get(vlc.object.input(), "time")
    vlc.msg.info("Stop-Time definido para: " .. stop_time .. " segundos.")
end

function select_m3u_file()
    m3u_file_path = vlc.dialog("Selecionar M3U").file_dialog("Selecionar arquivo M3U...", "*.m3u")
    if m3u_file_path then
        vlc.msg.info("Arquivo M3U selecionado: " .. m3u_file_path)
    else
        vlc.msg.warn("Nenhum arquivo M3U selecionado!")
    end
end

function append_to_m3u()
    if not start_time or not stop_time then
        vlc.msg.warn("Defina os tempos primeiro!")
        return
    end

    if not m3u_file_path then
        vlc.msg.warn("Selecione um arquivo M3U antes de adicionar!")
        return
    end

    local input_item = vlc.input.item()
    local uri = input_item:uri()
    local file_path = vlc.strings.decode_uri(uri)

    local m3u_entry = "\n#EXTINF:-1," .. input_item:name() .. "\n"
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
