local M = {}

function M.root(markers)
  markers = markers or { "mvnw", "pom.xml", "gradlew", "build.gradle", ".git" }
  local found = vim.fs.find(markers, { upward = true, path = vim.api.nvim_buf_get_name(0) })
  local uv = vim.uv or vim.loop
  return found[1] and vim.fs.dirname(found[1]) or uv.cwd()
end

function M.maven()
  local root = M.root()
  return vim.fn.executable(root .. "/mvnw") == 1 and "./mvnw" or "mvn", root
end

-- Parses simple KEY=VALUE lines without executing shell code or logging values.
function M.env(root)
  local result, path = {}, (root or M.root()) .. "/.env"
  if vim.fn.filereadable(path) == 0 then return result end
  for _, line in ipairs(vim.fn.readfile(path)) do
    local key, value = line:match("^%s*([%w_]+)%s*=%s*(.-)%s*$")
    if key and not line:match("^%s*#") then
      value = value:gsub("^['\"]", ""):gsub("['\"]$", "")
      result[key] = value
    end
  end
  return result
end

return M
