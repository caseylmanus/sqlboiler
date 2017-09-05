{{- $tableNamePlural := .Table.Name | plural | titleCase -}}
{{- $varNameSingular := .Table.Name | singular | camelCase}}


// {{$tableNamePlural}} retrieves all the records using an executor.
func {{$tableNamePlural}}(exec boil.Executor, mods ...qm.QueryMod) {{$varNameSingular}}Query {
	mods = append(mods, qm.From("{{.Table.Name | .SchemaTable}}"))
	return {{$varNameSingular}}Query{NewQuery(exec, mods...)}
}
