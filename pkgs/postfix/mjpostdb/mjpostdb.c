#include <stdio.h>
#include <stdlib.h>
#include <getopt.h>
#include <string.h>
#include <majordomo_rate_limit.h>

#define RATE_DB 0x01

MJ_DBS mj_postfix_dbs;
u_int32_t mj_dbs_open_flags;

int add_flag;
int del_flag;
int get_flag;

static const struct option longopts[] = 
  {
    {"add", no_argument, &add_flag, 1},
    {"del", no_argument, &del_flag, 1},
    {"get", no_argument, &get_flag, 1},
    {"uid", required_argument, 0, 'u'},
    {"db", required_argument, 0, 'b'},
    {"help", no_argument, 0, 'h'},
    {0, 0, 0, 0}
  };

static void print_help (char *);

int
main (int argc, char **argv)
{
  int optc;
  uid_t uid;
  size_t size;
  int ret;
  char *db;
  DBT key, data;

  char *prog_name = argv[0];
  while ((optc = getopt_long_only (argc, argv, "hadgu:b:", longopts, 0)) != -1) {
    switch (optc)
      {
      case ('h'):
	print_help (prog_name);
	exit (0);
      case ('u'):
	if (!optarg)
	  print_help(prog_name);
	else
	  uid = atoi(optarg);
	break;
      case ('b'):
	if (!optarg)
	  print_help;
	else
	  db = optarg;
	break;
      case ('a'):
	add_flag = 1;
	break;
      case ('d'):
	del_flag = 1;
	break;
      case ('g'):
	get_flag = 1;
	break;
      default:
	break;
      }
  }

  if (!(add_flag ^ get_flag ^ del_flag))
    print_help(prog_name);
  mj_initialize_dbs(&mj_postfix_dbs);
  mj_set_db_filenames(&mj_postfix_dbs);

  if (add_flag) {
    mj_dbs_open_flags = 0;
    mj_databases_setup(&mj_postfix_dbs, prog_name, stderr, mj_dbs_open_flags);
    if (!strcmp(db, "map")) {
      char val = 1;
      memset(&key, 0, sizeof(DBT));
      memset(&data, 0, sizeof(DBT));
      key.data = &uid;
      key.size = sizeof(uid_t);
      data.data = &val;
      data.size = sizeof(char);
      ret = mj_postfix_dbs.senders_map_db_pointer->put(mj_postfix_dbs.senders_map_db_pointer, NULL, &key, &data, 0);
      mj_databases_close(&mj_postfix_dbs);
      exit (ret);
    } else {
      puts ("--add option available only with map db");
      exit (0);
    }
  }

  if (del_flag) {
    mj_dbs_open_flags = 0;
    mj_databases_setup(&mj_postfix_dbs, prog_name, stderr, mj_dbs_open_flags);
    if (!strcmp(db, "map")) {
      memset(&key, 0, sizeof(DBT));
      key.data = &uid;
      key.size = sizeof(uid_t);
      ret = mj_postfix_dbs.senders_map_db_pointer->del(mj_postfix_dbs.senders_map_db_pointer, NULL, &key, 0);
      mj_databases_close(&mj_postfix_dbs);
      exit (ret);
    } else {
      puts ("--del option available only with map db");
      exit (0);
    }
  }

  if (get_flag) {
    mj_dbs_open_flags = DB_RDONLY;
    mj_databases_setup(&mj_postfix_dbs, prog_name, stderr, mj_dbs_open_flags);
    if (!strcmp(db, "map")) {
      short val;
      memset(&key, 0, sizeof(DBT));
      memset(&data, 0, sizeof(DBT));
      key.data = &uid;
      key.size = sizeof(uid_t);
      ret = mj_postfix_dbs.senders_map_db_pointer->get(mj_postfix_dbs.senders_map_db_pointer, NULL, &key, &data, 0);
      if (ret == DB_KEYEMPTY || ret == DB_NOTFOUND)
	printf ("UID %d not found in map db\n", uid);
      else
	printf ("UID %d found in map db\n", uid);
      mj_databases_close(&mj_postfix_dbs);
      exit (ret);
    } else if (!strcmp(db, "rate")) {
      short m_limit;
      memset(&key, 0, sizeof(DBT));
      memset(&data, 0, sizeof(DBT));

      key.data = &uid;
      key.size = sizeof(uid);

      ret = mj_postfix_dbs.senders_rate_db_pointer->get(mj_postfix_dbs.senders_rate_db_pointer, NULL, &key, &data, 0);
      if (ret == DB_KEYEMPTY || ret == DB_NOTFOUND)
	printf ("UID %d not found in rate db\n", uid);
      else {
	m_limit = *((short *) data.data);
	printf ("%d => %d\n", uid, m_limit);
      }
      mj_databases_close(&mj_postfix_dbs);
      exit (ret);
    } else if (!strcmp(db, "atime")) {
      unsigned atime;
      memset(&key, 0, sizeof(DBT));
      memset(&data, 0, sizeof(DBT));
      key.data = &uid;
      key.size = sizeof(uid_t);
      ret = mj_postfix_dbs.senders_atime_db_pointer->get(mj_postfix_dbs.senders_atime_db_pointer, NULL, &key, &data, 0);
      if (ret == DB_KEYEMPTY || ret == DB_NOTFOUND)
	printf ("UID %d not found in atime db\n", uid);
      else {
	atime = *((unsigned *) data.data);
	printf ("%d => %u\n", uid, atime);
      }
      mj_databases_close(&mj_postfix_dbs);
      exit (ret);
    }
  }

  exit (0);
}

static void
print_help (char *program_name)
{
  puts ("");
  printf ("Usage: %s --db rate --uid 12345 --get\n", program_name);
  puts ("");
  fputs ("\
-h, --help display this help and exit\n\
--add, -add, -a set working mode to add\n\
--get, -get, -g set working mode to get\n\
--del, -del, -d set working mode to del\n\
--db, -db, -b specify database. It's can be rate, map or atime\n\
--uid, -uid, -u specify user UID\n", stdout);
  puts ("");
  fputs ("\
Report bugs to: eng-list@mailman.majordomo.ru\n", stdout);
  puts ("");
}
