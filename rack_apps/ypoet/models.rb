module YPoet::Models
  class DUMMY < Base # force it to autoload
    ActiveRecord::Base.logger = $L
  end
  
  class Groundwork < V 0.1
    def self.up
      
=begin
CREATE TABLE KindConstants
(
 kind INT UNIQUE,
 user_visible CHAR(32) NOT NULL,
 klass_name CHAR(32) NOT NULL,
 body_check TEXT,
 PRIMARY KEY (kind)
); 
=end
      create_table KindConstant.table_name, :id => false do |t|
        t.primary_key :kind # hmm, INT UNIQUE, can be NULL, defaults to id usually
        t.string :user_visible, :limit => 32, :null => false # CHAR(32) NOT NULL,
        t.string :klass_name, :limit => 32, :null => false # CHAR(32) NOT NULL,
        # body_check TEXT,
        # execute "PRIMARY KEY (kind)"
        # This gives us created_at and updated_at (don't need for this simple table)
        # t.timestamps
      end
    
=begin
CREATE TABLE PoemPads
(
 pad_id INTEGER UNIQUE NOT NULL,
 description TEXT,
 PRIMARY KEY (pad_id)
);
=end

# alt tag of folder tree is desc?
      create_table PoemPad.table_name, :id => false do |t|
        t.primary_key :pad_id # , :null => false # hmm, INTEGER UNIQUE NOT NULL, defaults to id usually
        t.text :description # TEXT,
        # execute "PRIMARY KEY (pad_id)"
        # This gives us created_at and updated_at
        t.timestamps
      end
      
=begin
CREATE TABLE ePages
(
 epage_id INTEGER UNIQUE NOT NULL,
 pad_id INTEGER NOT NULL,
 label CHAR(32) NOT NULL,
 title CHAR(140),
 kind INT,
 body TEXT,
 FOREIGN KEY (pad_id) REFERENCES PoemPads(pad_id),
 FOREIGN KEY (kind) REFERENCES KindConstants(kind),
 PRIMARY KEY (epage_id)
); 
=end

      create_table EPage.table_name, :id => false do |t|
        t.primary_key :epage_id # hmm, INTEGER UNIQUE NOT NULL, defaults to id usually
        t.integer :pad_id, :null => false # INTEGER NOT NULL,
        t.string :label, :limit => 32, :null => false # CHAR(32) NOT NULL,
        t.string :title, :limit => 140 # CHAR(140),
        t.integer :kind # INT
        t.text :body # TEXT
        # add foreign keys and primary key
        # execute "PRIMARY KEY (epage_id)"
        # execute "FOREIGN KEY (pad_id) REFERENCES PoemPads(pad_id)"
        # ALTER TABLE #{EPage.table_name} ADD COLUMN pad_id REFERENCES PoemPads(pad_id)
        # execute "FOREIGN KEY (kind) REFERENCES KindConstants(kind)"
        # ALTER TABLE #{EPage.table_name} ADD COLUMN kind REFERENCES KindConstants(kind)
        # This gives us created_at and updated_at
        t.timestamps
      end

=begin
CREATE TABLE TreePaths
(
 parent_id INTEGER,
 epage_id INTEGER NOT NULL,
 depth INTEGER,
 PRIMARY KEY (parent_id, epage_id),
 FOREIGN KEY (parent_id) REFERENCES ePages(epage_id),
 FOREIGN KEY (epage_id) REFERENCES ePages(epage_id)
);
=end

      ActiveRecord::Base.connection.execute <<-SQL
        CREATE TABLE TreePaths
        (
         parent_id INTEGER,
         epage_id INTEGER NOT NULL,
         depth INTEGER,
         PRIMARY KEY (parent_id, epage_id),
         FOREIGN KEY (parent_id) REFERENCES ePages(epage_id),
         FOREIGN KEY (epage_id) REFERENCES ePages(epage_id)
        )
      SQL
      # create_table TreePath.table_name, :id => false do |t|
      #  t.primary_key :epage_id # hmm, INTEGER, defaults to id usually
      #  t.primary_key :epage_id, :null => false # hmm, INTEGER NOT NULL, defaults to id usually
      #  t.integer :depth # INTEGER,
      #  t.text :body # TEXT
      #  execute "PRIMARY KEY (parent_id, epage_id)"
      #  execute "FOREIGN KEY (parent_id) REFERENCES ePages(epage_id)"
      #  execute "FOREIGN KEY (epage_id) REFERENCES ePages(epage_id)"
      #  # This gives us created_at and updated_at
      #  t.timestamps # is this so important? might as well have them, dunno
      # end
      
    end

    def self.down
    end
  end
  
  class SeedData < V 0.2 # how to associate this data with my dev cookie?
    def self.up
      EPoem.db.execute_batch <<SQL
INSERT INTO "KindConstants" VALUES(#{EPoem.folder_kind},'Folder','Folder');
INSERT INTO "KindConstants" VALUES(1,'Singular','SingularPoem');
INSERT INTO "KindConstants" VALUES(2,'Re:Verse','ReversePoem');
INSERT INTO "KindConstants" VALUES(3,'Multi:Verse','MultiversePoem');
INSERT INTO "KindConstants" VALUES(4,'Trace:Verse','TraceversePoem');
SQL

      EPoem.db.execute_batch <<SQL
INSERT INTO "PoemPads" VALUES(3,'I made this. You play this. We consumate violently.',NULL,NULL);
SQL
      EPoem.db.execute_batch <<SQL
INSERT INTO "ePages" VALUES(1,3,'gwibber is a better name','fooisher',2,'--- 
:poem0: |-
  one
  
  blah blah blah foo
  
  another bit
:poem1: |-
  two
  
  blah blah blah
  
  i wandered lonely as a ePoem
',NULL,NULL);
INSERT INTO "ePages" VALUES(2,3,'fol de dol',NULL,#{EPoem.folder_kind},NULL,NULL,NULL);
INSERT INTO "ePages" VALUES(3,3,'singleton','',1,'--- 
:poem0: |-
  ok
  
  woohoo
  
  it should save
',NULL,NULL);
INSERT INTO "ePages" VALUES(4,3,'wimbledon','',1,'--- 
:poem0: ""
',NULL,NULL);
INSERT INTO "ePages" VALUES(5,3,'test',NULL,1,NULL,NULL,NULL);
INSERT INTO "ePages" VALUES(6,3,'another test',NULL,1,NULL,NULL,NULL);
INSERT INTO "ePages" VALUES(7,3,'rev rev','',2,'--- 
:poem0: "Dimmi: / com\xE2\x80\x99era con l\xE2\x80\x99altra, / pi\xC3\xB9 / semplice?\r\n\
  Dimmi: / com\xE2\x80\x99era con l\xE2\x80\x99altra, / meno / fragile?\r\n\
  Sembra / un vano \xE2\x80\xA6 / tentativo / di gelosia\r\n\
  Sembra / un vano \xE2\x80\xA6 / frugare / in / memorie\r\n\
  false, / fragili, / sporche.\r\n\
  Parole / precise / attraversano\r\n\
  fogli / bianchi / fermi / e / inutili.\r\n\
  Taccio / solo / odio /fino al collo\r\n\
  fino a qui, / fino a /rompere\r\n\
  lo spessore / che / adesso / ci / divide."
:poem1: "Taci: / non so se era, / pi\xC3\xB9 / seducente!\r\n\
  Taci: / non so se era, / meno / formale!\r\n\
  \xC3\x88 / un ridicolo \xE2\x80\xA6 / esempio / di tormento\r\n\
  \xC3\x88 / un ridicolo \xE2\x80\xA6 / piegarsi / in /paure\r\n\
  soffici, / lussuriose, / lente\r\n\
  Frasi / fraintese / lacerano\r\n\
  spazi / densi / rigidi / e / falsi\r\n\
  Dimmi: / ancora / amore / fino al collo\r\n\
  fino a qui, / fino a / cancellare\r\n\
  la fluidit\xC3\xA0 / che / ancora / ci / ferma."
',NULL,NULL);
INSERT INTO "ePages" VALUES(8,3,'example',NULL,4,NULL,NULL,NULL);
INSERT INTO "ePages" VALUES(9,3,'multi me',NULL,3,NULL,NULL,NULL);
INSERT INTO "ePages" VALUES(10,3,'ze_new_folder',NULL,#{EPoem.folder_kind},NULL,NULL,NULL);
INSERT INTO "ePages" VALUES(11,3,'groovilicious',NULL,#{EPoem.folder_kind},NULL,NULL,NULL);
INSERT INTO "ePages" VALUES(12,3,'yippity','',4,'--- 
:poem0: |-
  
  when you / go to / the mountain
  
  do not forget your / rock
:poem1: |-
  
  when you / come from / the mountain
  
  do not forget your / stick
:suggest_trace_text: go to / rock
:ignore_trace: 
',NULL,NULL);
INSERT INTO "ePages" VALUES(13,3,'qwerty',NULL,#{EPoem.folder_kind},NULL,NULL,NULL);
INSERT INTO "ePages" VALUES(14,3,'subby',NULL,#{EPoem.folder_kind},NULL,NULL,NULL);
INSERT INTO "ePages" VALUES(15,3,'subby',NULL,#{EPoem.folder_kind},NULL,NULL,NULL);
INSERT INTO "ePages" VALUES(17,3,'sss',NULL,1,NULL,NULL,NULL);
INSERT INTO "ePages" VALUES(18,3,'i am empty',NULL,#{EPoem.folder_kind},NULL,NULL,NULL);
INSERT INTO "ePages" VALUES(19,3,'i am new',NULL,#{EPoem.folder_kind},NULL,NULL,NULL);
INSERT INTO "ePages" VALUES(20,3,'example of re','',2,'--- 
:poem0: |-
  
  one
:poem1: |-
  
  two
',NULL,NULL);
INSERT INTO "ePages" VALUES(21,3,'Test','',1,'--- 
:poem0: Fffyfjfjhfj
',NULL,NULL);
INSERT INTO "ePages" VALUES(22,3,'Test',NULL,1,NULL,NULL,NULL);
INSERT INTO "ePages" VALUES(23,3,'fghjgd',NULL,1,NULL,NULL,NULL);
INSERT INTO "ePages" VALUES(24,3,'enderby',NULL,NULL,NULL,NULL,NULL);
INSERT INTO "ePages" VALUES(25,3,'simple single',NULL,1,NULL,NULL,NULL);
SQL

      EPoem.db.execute_batch <<SQL
INSERT INTO "TreePaths" VALUES(#{EPoem.top_folder},1,NULL);
INSERT INTO "TreePaths" VALUES(#{EPoem.top_folder},2,NULL);
INSERT INTO "TreePaths" VALUES(2,3,NULL);
INSERT INTO "TreePaths" VALUES(2,4,NULL);
INSERT INTO "TreePaths" VALUES(2,5,NULL);
INSERT INTO "TreePaths" VALUES(2,6,NULL);
INSERT INTO "TreePaths" VALUES(#{EPoem.top_folder},7,NULL);
INSERT INTO "TreePaths" VALUES(#{EPoem.top_folder},8,NULL);
INSERT INTO "TreePaths" VALUES(#{EPoem.top_folder},9,NULL);
INSERT INTO "TreePaths" VALUES(#{EPoem.top_folder},10,NULL);
INSERT INTO "TreePaths" VALUES(#{EPoem.top_folder},11,NULL);
INSERT INTO "TreePaths" VALUES(11,12,NULL);
INSERT INTO "TreePaths" VALUES(#{EPoem.top_folder},13,NULL);
INSERT INTO "TreePaths" VALUES(11,14,NULL);
INSERT INTO "TreePaths" VALUES(13,15,NULL);
INSERT INTO "TreePaths" VALUES(15,17,NULL);
INSERT INTO "TreePaths" VALUES(13,18,NULL);
INSERT INTO "TreePaths" VALUES(#{EPoem.top_folder},19,NULL);
INSERT INTO "TreePaths" VALUES(19,20,NULL);
INSERT INTO "TreePaths" VALUES(19,21,NULL);
INSERT INTO "TreePaths" VALUES(19,22,NULL);
INSERT INTO "TreePaths" VALUES(19,23,NULL);
INSERT INTO "TreePaths" VALUES(2,24,NULL);
INSERT INTO "TreePaths" VALUES(#{EPoem.top_folder},25,NULL);
SQL
    end
    
    def self.down
      
    end
  end
  
  class Versioning < V 0.3
    def self.up
      create_table :vestalversions_versions do |t|
        t.belongs_to :versioned, :polymorphic => true
        t.belongs_to :user, :polymorphic => true
        t.string  :user_name
        t.text    :modifications
        t.integer :number
        t.integer :reverted_from
        t.string  :tag
  
        t.timestamps
      end
  
      change_table :vestalversions_versions do |t|
        t.index [:versioned_id, :versioned_type]
        t.index [:user_id, :user_type]
        t.index :user_name
        t.index :number
        t.index :tag
        t.index :created_at
      end
      # add versioning to appropriate class now that we have it
      EPage.enable_versioning
    end
    
    def self.down
      # remove versioning yada yada yada 
      EPage.disable_versioning
      drop_table :versions
    end
  end
  
    class PerBrowserPoemPad < V 0.4
    # 
    def self.up
      change_table PoemPad.table_name do |t|
        t.string :unique_id, :limit => 64 # should be NOT NUL :(
      end
      PoemPad.find(3).update_attribute(:unique_id, "92dae58c93ce1cd9cf5728f8b02b955a392bcc64b89ad8d8a4200bbbb9e04c61");
    end
  
    def self.down
      change_table PoemPad.table_name do |t|
        t.remove :unique_id
      end
    end
  end
end
