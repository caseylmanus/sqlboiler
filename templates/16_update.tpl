{{- $tableNameSingular := .Table.Name | singular | titleCase -}}
{{- $varNameSingular := .Table.Name | singular | camelCase -}}
{{- $schemaTable := .Table.Name | .SchemaTable}}


// Update uses an executor to update the {{$tableNameSingular}}.
// Whitelist behavior: If a whitelist is provided, only the columns given are updated.
// No whitelist behavior: Without a whitelist, columns are inferred by the following rules:
// - All columns are inferred to start with
// - All primary keys are subtracted from this set
func (o *{{$tableNameSingular}}) Update(exec boil.Executor, whitelist ... string) error {
	{{- template "timestamp_update_helper" . -}}

	var err error

	key := makeCacheKey(whitelist, nil)
	{{$varNameSingular}}UpdateCacheMut.RLock()
	cache, cached := {{$varNameSingular}}UpdateCache[key]
	{{$varNameSingular}}UpdateCacheMut.RUnlock()

	if !cached {
		wl := strmangle.UpdateColumnSet(
			{{$varNameSingular}}Columns,
			{{$varNameSingular}}PrimaryKeyColumns,
			whitelist,
		)
		{{if eq .DriverName "mssql"}}
		wl = strmangle.SetComplement(wl, {{$varNameSingular}}ColumnsWithAuto)
		{{end}}
		{{if not .NoAutoTimestamps}}
		if len(whitelist) == 0 {
			wl = strmangle.SetComplement(wl, []string{"created_at"})
		}
		{{end -}}
		if len(wl) == 0 {
			return errors.New("{{.PkgName}}: unable to update {{.Table.Name}}, could not build whitelist")
		}

		cache.query = fmt.Sprintf("UPDATE {{$schemaTable}} SET %s WHERE %s",
			strmangle.SetParamNames("{{.LQ}}", "{{.RQ}}", {{if .Dialect.IndexPlaceholders}}1{{else}}0{{end}}, wl),
			strmangle.WhereClause("{{.LQ}}", "{{.RQ}}", {{if .Dialect.IndexPlaceholders}}len(wl)+1{{else}}0{{end}}, {{$varNameSingular}}PrimaryKeyColumns),
		)
		cache.valueMapping, err = queries.BindMapping({{$varNameSingular}}Type, {{$varNameSingular}}Mapping, append(wl, {{$varNameSingular}}PrimaryKeyColumns...))
		if err != nil {
			return err
		}
	}

	values := queries.ValuesFromMapping(reflect.Indirect(reflect.ValueOf(o)), cache.valueMapping)


	_, err = exec.Exec(cache.query, values...)
	if err != nil {
		return errors.Wrap(err, "{{.PkgName}}: unable to update {{.Table.Name}} row")
	}

	if !cached {
		{{$varNameSingular}}UpdateCacheMut.Lock()
		{{$varNameSingular}}UpdateCache[key] = cache
		{{$varNameSingular}}UpdateCacheMut.Unlock()
	}

	return nil
}


