{{- $tableNameSingular := .Table.Name | singular | titleCase -}}
{{- $varNameSingular := .Table.Name | singular | camelCase -}}
{{- $schemaTable := .Table.Name | .SchemaTable}}


// Delete deletes a single {{$tableNameSingular}} record with an executor.
// Delete will match against the primary key column to find the record to delete.
func (o *{{$tableNameSingular}}) Delete(exec boil.Executor) error {
	if o == nil {
	return errors.New("{{.PkgName}}: no {{$tableNameSingular}} provided for delete")
	}

	args := queries.ValuesFromMapping(reflect.Indirect(reflect.ValueOf(o)), {{$varNameSingular}}PrimaryKeyMapping)
	sql := "DELETE FROM {{$schemaTable}} WHERE {{if .Dialect.IndexPlaceholders}}{{whereClause .LQ .RQ 1 .Table.PKey.Columns}}{{else}}{{whereClause .LQ .RQ 0 .Table.PKey.Columns}}{{end}}"


	_, err := exec.Exec(sql, args...)
	if err != nil {
	return errors.Wrap(err, "{{.PkgName}}: unable to delete from {{.Table.Name}}")
	}

	return nil
}

