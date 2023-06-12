from pathlib import Path

def read_csv(filepath: Path, target_indexes: set[int] | None = None) -> tuple[list[str], list[list[str]], list[list[str]]]:
    with filepath.open() as file:
        lines = file.read().splitlines()

        labels = list()

        # First line is label and first column is ignored
        for label in  lines[0].split(',')[1:]:
            labels.append(label)
        
        
        # If None consider the last column the only target
        if target_indexes is None:
            target_indexes = {len(lines[0].split(',')) - 2}

        # Check the element type of each element in the second line (first line of data)
        line = lines[1].split(',')[1:]
        mapping_tables = dict()
        elements_types = list()
        datum = list()
        target = list()

        for index in range(len(line)):
            element = line[index]
            try:
                element = int(element)
                value_type = int
            except ValueError:
                try:
                    element = float(element)
                    value_type = float
                except ValueError:
                    element = 0
                    value_type = str
                    mapping_table = [element]
                    mapping_tables[index] = mapping_table
            
            elements_types.append(value_type)

            if index in target_indexes:
                target.append(element)
            else:
                datum.append(element)

        # Fill the database with all the following lines
        data = [datum]
        targets = [target]

        for line in lines[2:]:
            line_splitted = line.split(',')[1:]
            datum = list()
            target = list()

            for i in range(len(line_splitted)):
                element = line_splitted[i]

                if elements_types[i] == str:
                    mapping_table : list[str] = mapping_tables[i]
                    if element not in mapping_table:
                        mapping_table.append(element)
                    
                    element = mapping_table.index(element)
                else:
                    element = elements_types[i](element)

                if i in target_indexes:
                    target.append(element)
                else:
                    datum.append(element)
            
            data.append(datum)
            targets.append(target)
        
    return labels, data, targets

