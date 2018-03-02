{{- define "relationship_to_one_struct_helper" -}}
{{- end -}}

{{- $dot := . -}}
{{- $tableNameSingular := .Table.Name | singular -}}
{{- $modelName := $tableNameSingular | titleCase -}}
{{- $modelNameCamel := $tableNameSingular | camelCase -}}
// {{$modelName}} is an object representing the database table.
type {{$modelName}} struct {
	{{range $column := .Table.Columns -}}
	{{titleCase $column.Name}} {{$column.Type}} `boil:"{{$column.Name}}" json:"{{camelCase $column.Name}}{{if $column.Nullable}},omitempty{{end}}"`
	{{end -}}
	{{- if .Table.IsJoinTable -}}
	{{- else}}
	{{range .Table.FKeys -}}
	{{- $txt := txtsFromFKey $dot.Tables $dot.Table . -}}
	{{$txt.Function.Name}} *{{$txt.ForeignTable.NameGo}} `json:"{{$txt.Function.Name}},omitempty"`
	{{end -}}

	{{range .Table.ToOneRelationships -}}
	{{- $txt := txtsFromOneToOne $dot.Tables $dot.Table . -}}
	{{$txt.Function.Name}} *{{$txt.ForeignTable.NameGo}} `json:"{{$txt.Function.Name}},omitempty"`
	{{end -}}

	{{range .Table.ToManyRelationships -}}
	{{- $txt := txtsFromToMany $dot.Tables $dot.Table . -}}
	{{$txt.Function.Name}} {{$txt.ForeignTable.Slice}} `json:"{{$txt.Function.Name}}"`
	{{end -}}{{/* range tomany */}}
	{{end -}}
}
//{{$modelName}}Columns is a struct with all columns for the entity
var {{$modelName}}Columns = struct {
	{{range $column := .Table.Columns -}}
	{{titleCase $column.Name}} string
	{{end -}}
}{
	{{range $column := .Table.Columns -}}
	{{titleCase $column.Name}}: "{{$column.Name}}",
	{{end -}}
}
