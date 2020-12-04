----------------------------------------------------------------------------------
--Copyright 2020 Ricardo F Tafas Jr

--Licensed under the Apache License, Version 2.0 (the "License"); you may not
--use this file except in compliance with the License. You may obtain a copy of
--the License at

--   http://www.apache.org/licenses/LICENSE-2.0

--Unless required by applicable law or agreed to in writing, software distributed
--under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES
--OR CONDITIONS OF ANY KIND, either express or implied. See the License for
--the specific language governing permissions and limitations under the License.
----------------------------------------------------------------------------------
library IEEE;
  use IEEE.STD_LOGIC_1164.ALL;
library expert;
    use expert.std_string.all;

package vhls_lib is

  type procedure_status_t is ( BUSY, READY, DONE, PERROR);

  constant max_proc_name : positive := 32;
  constant max_proc_list : positive := 8;

  type procedure_list_t is array (0 to max_proc_list-1) of string(1 to max_proc_name);

  type handler_t is record
    current_process  : natural;
    procedure_list   : procedure_list_t;
    procedure_status : procedure_status_t;
    total_procedures : natural;
  end record handler_t;

  type pipeline_handler_t is array (NATURAL RANGE <> ) of handler_t;

  constant runner_start : handler_t := (
    current_process  => 0,
    procedure_list   => (others=>(others=>nul)),
    procedure_status => READY,
    total_procedures => 0
  );

  procedure run
    generic (
      process_name : string;
      type          my_procedure_handler_t;
      procedure     my_procedure(signal my_procedure_data : inout my_procedure_handler_t; my_status : out procedure_status_t)
    )
    parameter (
      runner : inout handler_t;
      signal my_procedure_data : inout my_procedure_handler_t
    );

  procedure runv
    generic (
      process_name : string;
      type          my_procedure_handler_t;
      procedure     my_procedure(my_procedure_data : inout my_procedure_handler_t; my_status : out procedure_status_t)
    )
    parameter (
      runner            : inout handler_t;
      my_procedure_data : inout my_procedure_handler_t
    );

    procedure add_procedure(runner : inout handler_t; procname : in string);

    procedure scheduler_procedure(runner : inout handler_t);

end package;

package body vhls_lib is

  procedure run
    generic (
      process_name : string;
      type          my_procedure_handler_t;
      procedure     my_procedure(signal my_procedure_data : inout my_procedure_handler_t; my_status : out procedure_status_t)
    )
    parameter (
      runner       : inout handler_t;
      signal my_procedure_data : inout my_procedure_handler_t
    ) is
      variable proc_name_tmp : string(1 to max_proc_name) := (others => nul);
  begin
    proc_name_tmp := string_padding(process_name,max_proc_name);
    runner := runner;
    add_procedure(runner,process_name);
    if proc_name_tmp = runner.procedure_list(runner.current_process) then
      my_procedure(my_procedure_data,runner.procedure_status);
    end if;
  end procedure;

  procedure runv
    generic (
      process_name : string;
      type          my_procedure_handler_t;
      procedure     my_procedure(my_procedure_data : inout my_procedure_handler_t; my_status : out procedure_status_t)
    )
    parameter (
      runner            : inout handler_t;
      my_procedure_data : inout my_procedure_handler_t
    ) is
      variable proc_name_tmp : string(1 to max_proc_name) := (others => nul);
  begin
    proc_name_tmp := string_padding(process_name,max_proc_name);
    runner := runner;
    add_procedure(runner,process_name);
    if proc_name_tmp = runner.procedure_list(runner.current_process) then
      my_procedure(my_procedure_data,runner.procedure_status);
      scheduler_procedure(runner);
    end if;
  end procedure;

  procedure add_procedure(runner : inout handler_t; procname : in string) is
    constant null_c : string(1 to max_proc_name) := (others => nul);
    variable proc_name_tmp : string(1 to max_proc_name) := (others => nul);
  begin
    proc_name_tmp := string_padding(procname,max_proc_name);
    runner := runner;
    for j in 0 to max_proc_list-1 loop
      --if proc_name_tmp = runner.procedure_list(j) then
      exit when proc_name_tmp = runner.procedure_list(j);
      if runner.procedure_list(j) = null_c then
        runner.procedure_list(j) := proc_name_tmp;
        runner.total_procedures  := runner.total_procedures + 1;
        exit;
      end if;
    end loop;
  end add_procedure;

  procedure scheduler_procedure(runner : inout handler_t) is
  begin
    runner := runner;
    if runner.procedure_status /= BUSY then
        runner.current_process := runner.current_process + 1;
        if runner.current_process >= runner.total_procedures then
            runner.current_process := 0;
        end if;
    else
      runner.procedure_status := READY;
    end if;
  end scheduler_procedure;

end package body;
