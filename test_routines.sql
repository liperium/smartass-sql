do
$$
    declare
        result refcursor = 'generated_result_cursor';
    begin
        open result for select *
                        from api.add_agenda_item(
                                _auth_id := '65a5758ad4b8f0d7b410f1a0',
                                _title := 'Cuisine Added 1',
                                _description := 'Manger 2',
                                _importance := 0,
                                _startts := '2024-02-09 12:00:00',
                                _endts := '2024-02-09 13:00:00'
                             );
    end
$$;

SELECT *
FROM api.get_agenda_item('65a5758ad4b8f0d7b410f1a0');

SELECT *
FROM hdpdb.api.add_agenda_item('65a5758ad4b8f0d7b410f1a0', 'Menage 3', 'Manger dans la cuisine', 0,
                               '2024-02-09 13:21:15.000000',
                               '2024-02-09 16:21:19.000000');