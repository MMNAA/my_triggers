CREATE OR REPLACE TRIGGER trg_instead_of_insert_all_workers_elapsed
INSTEAD OF INSERT ON ALL_WORKERS_ELAPSED
FOR EACH ROW
BEGIN
    INSERT INTO workers_factory_1 (id, first_name, last_name, age, first_day, last_day)
    VALUES (:NEW.worker_id, :NEW.first_name, :NEW.last_name, :NEW.age, :NEW.start_date, NULL);
    
    INSERT INTO workers_factory_2 (worker_id, first_name, last_name, start_date, end_date)
    VALUES (:NEW.worker_id, :NEW.first_name, :NEW.last_name, :NEW.start_date, NULL);
END;

CREATE OR REPLACE TRIGGER trg_instead_of_update_all_workers_elapsed
INSTEAD OF UPDATE ON ALL_WORKERS_ELAPSED
FOR EACH ROW
BEGIN
    RAISE_APPLICATION_ERROR(-20001, 'Updating is not allowed on ALL_WORKERS_ELAPSED view.');
END;

CREATE OR REPLACE TRIGGER trg_instead_of_delete_all_workers_elapsed
INSTEAD OF DELETE ON ALL_WORKERS_ELAPSED
FOR EACH ROW
BEGIN
    RAISE_APPLICATION_ERROR(-20002, 'Deleting is not allowed on ALL_WORKERS_ELAPSED view.');
END;

CREATE OR REPLACE TRIGGER TRG_ROBOT_ADDITION
BEFORE INSERT ON robots
FOR EACH ROW
BEGIN
    INSERT INTO audit_robot (robot_id, created_at)
    VALUES (:NEW.id, SYSDATE);
END;

CREATE OR REPLACE TRIGGER TRG_ROBOTS_FACTORIES_BEFORE_INSERT_UPDATE_DELETE
INSTEAD OF INSERT OR UPDATE OR DELETE ON ROBOTS_FACTORIES
FOR EACH ROW
BEGIN
    IF num_factories != num_worker_tables THEN
        RAISE_APPLICATION_ERROR(-20001, 'Le nombre d''usines dans la table "FACTORIES" n''est pas égal au nombre de tables respectant le format "WORKERS_FACTORY_<N>". La modification de données via la vue "ROBOTS_FACTORIES" est interdite.');
    END IF;
END TRG_ROBOTS_FACTORIES_BEFORE_INSERT_UPDATE_DELETE;

CREATE OR REPLACE TRIGGER trg_calculate_duration
BEFORE INSERT OR UPDATE ON workers_factory_2
FOR EACH ROW
BEGIN
    IF :NEW.last_day IS NOT NULL THEN
        SELECT start_date INTO v_start_date
        FROM workers_factory_2
        WHERE worker_id = :NEW.worker_id;

        v_duration := TRUNC(:NEW.last_day - v_start_date);

        :NEW.duration := v_duration;
    END IF;
END;